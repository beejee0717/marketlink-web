import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

Future<void> generatePdfReport(DateTime selectedMonth) async {
  final font =
      pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
  final pdf = pw.Document();

  final String monthYear = DateFormat('MMMM yyyy').format(selectedMonth);

  Uint8List logoBytes = await rootBundle
      .load('images/logo.png')
      .then((value) => value.buffer.asUint8List());
  final logoImage = pw.MemoryImage(logoBytes);

  final reportData = await fetchSalesReportData(selectedMonth);

  pdf.addPage(
    pw.MultiPage(
      theme: pw.ThemeData.withFont(base: font),
      build: (context) => [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            pw.SizedBox(width: 20),
            pw.Column(
              children: [
                pw.Text("MarketLink",
                    style: pw.TextStyle(
                        fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.Text("Sales Report for the month of $monthYear"),
              ],
            ),
            pw.Image(logoImage, width: 60),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: "TOTAL SALES THIS MONTH: ",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.TextSpan(
                text: "₱${reportData['totalSales'].toStringAsFixed(2)}",
                style: const pw.TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 30),

        // Top Sellers
        pw.Text("Top 3 Sellers",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        reportData['topSellers'].isEmpty
            ? pw.Text("No sellers data available.",
                style: const pw.TextStyle(fontSize: 12))
            : pw.TableHelper.fromTextArray(
                headers: [
                  "Seller Name",
                  "Total Sales this Month",
                  "Products Sold"
                ],
                headerStyle:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 12),
                cellAlignment: pw.Alignment.centerLeft,
                border: pw.TableBorder.all(),
                data: reportData['topSellers']
                    .map<List<String>>((seller) => [
                          seller['name'].toString(),
                          "₱${seller['sales'].toString()}",
                          seller['quantity'].toString(),
                        ])
                    .toList(),
              ),

        pw.SizedBox(height: 20),

        pw.Text("Top 3 Products",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        reportData['topProducts'].isEmpty
            ? pw.Text("No product data available.",
                style: const pw.TextStyle(fontSize: 12))
            : pw.TableHelper.fromTextArray(
                headers: [
                  "Product Name",
                  "Total Sales this Month",
                  "Quantity Sold"
                ],
                headerStyle:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 12),
                cellAlignment: pw.Alignment.centerLeft,
                border: pw.TableBorder.all(),
                data: reportData['topProducts']
                    .map<List<String>>((product) => [
                          product['name'].toString(),
                          "₱${product['sales'].toString()}",
                          product['quantity'].toString(),
                        ])
                    .toList(),
              ),

        pw.SizedBox(height: 20),

        pw.Text("Top 3 Riders",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        reportData['topRiders'].isEmpty
            ? pw.Text("No rider data available.",
                style: const pw.TextStyle(fontSize: 12))
            : pw.TableHelper.fromTextArray(
                headers: ["Name", "Number of Deliveries"],
                headerStyle:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 12),
                cellAlignment: pw.Alignment.centerLeft,
                border: pw.TableBorder.all(),
                data: reportData['topRiders']
                    .map<List<String>>((rider) => [
                          rider['name'].toString(),
                          rider['deliveries'].toString(),
                        ])
                    .toList(),
              ),
      ],
    ),
  );

  final bytes = await pdf.save();
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute("download", "MarketLink_Sales_Report_$monthYear.pdf")
    ..click();

  html.Url.revokeObjectUrl(url);
}

Future<Map<String, dynamic>> fetchSalesReportData(DateTime month) async {
  final firestore = FirebaseFirestore.instance;

  final startDate = DateTime(month.year, month.month, 1);
  final endDate = month.month == 12
      ? DateTime(month.year + 1, 1, 1)
      : DateTime(month.year, month.month + 1, 1);

  final start = Timestamp.fromDate(startDate);
  final end = Timestamp.fromDate(endDate);

  debugPrint("Fetching orders between: $startDate and $endDate");

  final ordersSnapshot = await firestore
      .collection('orders')
      .where('deliveryTimestamp', isGreaterThanOrEqualTo: start)
      .where('deliveryTimestamp', isLessThan: end)
      .where('status', isEqualTo: 'delivered')
      .get();

  debugPrint("Orders retrieved: ${ordersSnapshot.docs.length}");

  double totalSales = 0;
  Map<String, Map<String, dynamic>> sellerStats = {};
  Map<String, Map<String, dynamic>> productStats = {};
  Map<String, int> riderDeliveries = {};

  for (var doc in ordersSnapshot.docs) {
    final data = doc.data();

    final double price = (data['price'] ?? 0).toDouble();
    final int qty = (data['quantity'] ?? 0).toInt();
    final String sellerId = data['sellerId'] ?? '';
    final String productId = data['productId'] ?? '';
    final String? riderId = data['riderId'];

    totalSales += price * qty;

    // Sellers
    if (sellerId.isNotEmpty) {
      sellerStats[sellerId] ??= {'sales': 0.0, 'quantity': 0};
      sellerStats[sellerId]!['sales'] += price * qty;
      sellerStats[sellerId]!['quantity'] += qty;
    }

    // Products
    if (productId.isNotEmpty) {
      productStats[productId] ??= {'sales': 0.0, 'quantity': 0};
      productStats[productId]!['sales'] += price * qty;
      productStats[productId]!['quantity'] += qty;
    }

    // Riders
    if (riderId != null && riderId.trim().isNotEmpty) {
      riderDeliveries[riderId] = (riderDeliveries[riderId] ?? 0) + 1;
    }
  }

  debugPrint("Total sales: $totalSales");
  debugPrint("Sellers found: ${sellerStats.length}");
  debugPrint("Products found: ${productStats.length}");
  debugPrint("Riders found: ${riderDeliveries.length}");

  final sellerIds = sellerStats.keys.toList();
  final productIds = productStats.keys.toList();
  final riderIds = riderDeliveries.keys.toList();

  final sellerFutures = sellerIds.map((id) async {
    final snap = await firestore.collection('sellers').doc(id).get();
    final data = snap.data();
    final name = data == null
        ? 'Unknown'
        : "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
    return MapEntry(id, name.isEmpty ? 'Unknown' : name);
  });

  final productFutures = productIds.map((id) async {
    final snap = await firestore.collection('products').doc(id).get();
    final name = snap.data()?['productName'] ?? 'Unknown';
    return MapEntry(id, name);
  });

  final riderFutures = riderIds.map((id) async {
    final snap = await firestore.collection('riders').doc(id).get();
    final data = snap.data();
    final name = data == null
        ? 'Unknown'
        : "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
    return MapEntry(id, name.isEmpty ? 'Unknown' : name);
  });

  final sellerNames = Map.fromEntries(await Future.wait(sellerFutures));
  final productNames = Map.fromEntries(await Future.wait(productFutures));
  final riderNames = Map.fromEntries(await Future.wait(riderFutures));

  List<Map<String, dynamic>> topSellers = [];
  final sortedSellers = sellerStats.entries.toList()
    ..sort((a, b) => b.value['sales'].compareTo(a.value['sales']));
  for (var entry in sortedSellers.take(3)) {
    final name = sellerNames[entry.key] ?? 'Unknown';
    topSellers.add({
      'name': name,
      'sales': entry.value['sales'].toStringAsFixed(2),
      'quantity': entry.value['quantity'],
    });
  }

  List<Map<String, dynamic>> topProducts = [];
  final sortedProducts = productStats.entries.toList()
    ..sort((a, b) => b.value['sales'].compareTo(a.value['sales']));
  for (var entry in sortedProducts.take(3)) {
    final name = productNames[entry.key] ?? 'Unknown';
    topProducts.add({
      'name': name,
      'sales': entry.value['sales'].toStringAsFixed(2),
      'quantity': entry.value['quantity'],
    });
  }

  List<Map<String, dynamic>> topRiders = [];
  final sortedRiders = riderDeliveries.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  for (var entry in sortedRiders.take(3)) {
    final name = riderNames[entry.key] ?? 'Unknown';
    topRiders.add({
      'name': name,
      'deliveries': entry.value,
    });
  }

  return {
    'totalSales': totalSales,
    'topSellers': topSellers,
    'topProducts': topProducts,
    'topRiders': topRiders,
  };
}

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketlinkweb/components/loading.dart';
import 'package:marketlinkweb/pages/customers.dart';
import 'package:marketlinkweb/pages/products.dart';
import 'package:marketlinkweb/pages/riders.dart';
import 'package:marketlinkweb/pages/sellers.dart';

class Dashboard extends StatefulWidget {
  final Function(Widget) onPageSelected;

  const Dashboard({super.key, required this.onPageSelected});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  int customerCount = 0;
  int sellerCount = 0;
  int riderCount = 0;
  int activeOrders = 0;
  int deliveredOrders = 0;
  int pendingSellerCount = 0;
  int pendingRiderCount = 0;
  bool isLoading = true;
  bool isSalesLoading = false;
  Map<String, double> salesPerDay = {};
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadCounts(_selectedMonth);
  }

  void loadCounts(DateTime selectedMonth) async {
    setState(() {
      isSalesLoading = true;
    });
    final customers =
        await FirebaseFirestore.instance.collection('customers').get();

    final sellers = await FirebaseFirestore.instance
        .collection('sellers')
        .where('approved', isEqualTo: true)
        .get();

    final sellerNotApproved = await FirebaseFirestore.instance
        .collection('sellers')
        .where('approved', isEqualTo: false)
        .get();

    final riders = await FirebaseFirestore.instance
        .collection('riders')
        .where('approved', isEqualTo: true)
        .get();
    final riderNotApproved = await FirebaseFirestore.instance
        .collection('riders')
        .where('approved', isEqualTo: false)
        .get();

    final ordersDelivered = await FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'delivered')
        .get();
    final ordersNotDelivered = await FirebaseFirestore.instance
        .collection('orders')
        .where('status', isNotEqualTo: 'delivered')
        .get();

    final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final endOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
    final salesQuery = await FirebaseFirestore.instance
        .collection('orders')
        .where('dateOrdered',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('dateOrdered', isLessThan: Timestamp.fromDate(endOfMonth))
        .get();

    Map<String, double> tempSales = {};

    for (var doc in salesQuery.docs) {
      final date = (doc['dateOrdered'] as Timestamp).toDate();
      final key = DateFormat('MM/dd').format(date);
      final total = (doc['totalPayment'] as num).toDouble();

      if (tempSales.containsKey(key)) {
        tempSales[key] = tempSales[key]! + total;
      } else {
        tempSales[key] = total;
      }
    }

    setState(() {
      customerCount = customers.size;
      sellerCount = sellers.size;
      riderCount = riders.size;
      activeOrders = ordersNotDelivered.size;
      deliveredOrders = ordersDelivered.size;
      pendingSellerCount = sellerNotApproved.size;
      pendingRiderCount = riderNotApproved.size;
      salesPerDay = tempSales;
      isLoading = false;
      isSalesLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 239, 249),
      ),
      child: isLoading
          ? const Center(child: Loading())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FadeInLeft(
                          child: Text(
                            'MarketLink',
                            style: TextStyle(
                                fontSize: isMobile ? 20 : 50,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        summaryCard(
                          'Customers',
                          customerCount,
                          Icons.people,
                          Colors.purple,
                          onTap: () {
                            widget.onPageSelected(const Customers());
                          },
                        ),
                        summaryCard(
                          'Sellers',
                          sellerCount,
                          Icons.store,
                          Colors.teal,
                          badgeCount: pendingSellerCount,
                          onTap: () {
                            widget.onPageSelected(const Sellers());
                          },
                        ),
                        summaryCard(
                          'Riders',
                          riderCount,
                          Icons.motorcycle,
                          Colors.orange,
                          badgeCount: pendingRiderCount,
                          onTap: () {
                            widget.onPageSelected(const Riders());
                          },
                        ),
                        summaryCard(
                          'Orders',
                          deliveredOrders,
                          Icons.shopping_cart,
                          Colors.blue,
                          badgeCount: activeOrders,
                          onTap: () {
                            widget.onPageSelected(const Products());
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '📊 Monthly Sales Overview',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_left),
                                    onPressed: () {
                                      setState(() {
                                        _selectedMonth = DateTime(
                                            _selectedMonth.year,
                                            _selectedMonth.month - 1);
                                        loadCounts(_selectedMonth);
                                      });
                                    },
                                  ),
                                  Text(
                                    DateFormat.yMMMM().format(_selectedMonth),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_right),
                                    onPressed: _selectedMonth.month ==
                                                DateTime.now().month &&
                                            _selectedMonth.year ==
                                                DateTime.now().year
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedMonth = DateTime(
                                                  _selectedMonth.year,
                                                  _selectedMonth.month + 1);
                                              loadCounts(_selectedMonth);
                                            });
                                          },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.4),
                                  width: 1),
                            ),
                            child: SizedBox(
                              height: 300,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Opacity(
                                    opacity: isSalesLoading ? 0.3 : 1,
                                    child: BarChart(
                                      BarChartData(
                                        barTouchData: BarTouchData(
                                          enabled: true,
                                          touchTooltipData: BarTouchTooltipData(
                                            tooltipBgColor: Colors.black87,
                                            getTooltipItem: (group, groupIndex,
                                                rod, rodIndex) {
                                              final day = salesPerDay.keys
                                                  .elementAt(group.x.toInt());
                                              final amount =
                                                  rod.toY.toStringAsFixed(2);
                                              return BarTooltipItem(
                                                '₱$amount\n$day',
                                                const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              );
                                            },
                                          ),
                                        ),
                                        alignment:
                                            BarChartAlignment.spaceAround,
                                        maxY: _calculateMaxY(salesPerDay),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              reservedSize: 50,
                                              showTitles: true,
                                              interval: _calculateInterval(
                                                  salesPerDay),
                                              getTitlesWidget: (value, meta) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 4),
                                                  child: Text(
                                                    '₱${value.toInt()}',
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 36,
                                              interval: 1,
                                              getTitlesWidget: (value, meta) {
                                                final index = value.toInt();
                                                if (index >=
                                                    salesPerDay.keys.length) {
                                                  return const SizedBox
                                                      .shrink();
                                                }
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 6.0),
                                                  child: Text(
                                                    salesPerDay.keys
                                                        .elementAt(index),
                                                    style: const TextStyle(
                                                        fontSize: 10),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                          topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          horizontalInterval:
                                              _calculateInterval(salesPerDay),
                                          getDrawingHorizontalLine: (value) =>
                                              FlLine(
                                            color: Colors.grey.withOpacity(0.2),
                                            strokeWidth: 1,
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        barGroups: salesPerDay.entries
                                            .toList()
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final index = entry.key;
                                          final value = entry.value.value;
                                          return BarChartGroupData(
                                            x: index,
                                            barRods: [
                                              BarChartRodData(
                                                toY: value,
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Colors.purpleAccent,
                                                    Colors.deepPurple,
                                                  ],
                                                ),
                                                width: 14,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  if (isSalesLoading)
                                    const Text(
                                      'Loading data...',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  double _calculateMaxY(Map<String, double> data) {
    if (data.isEmpty) return 100;
    final max = data.values.reduce((a, b) => a > b ? a : b);
    return (max / 100).ceil() * 100 + 100;
  }

  double _calculateInterval(Map<String, double> data) {
    final maxY = _calculateMaxY(data);
    return (maxY / 5).ceilToDouble();
  }

  Widget summaryCard(
    String title,
    int count,
    IconData icon,
    Color color, {
    int badgeCount = 0,
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: title == 'Sellers'
          ? 'Number of Approved Sellers'
          : title == 'Customers'
              ? 'Number of Customers'
              : title == 'Riders'
                  ? 'Number of Approved Rider'
                  : title == 'Orders'
                      ? 'Number of Orders Delivered'
                      : 'Unknown section',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              width: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: color, size: 30),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$count',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Tooltip(
                  message: title == 'Orders'
                      ? 'Active $title: $badgeCount'
                      : '$title Waiting for Approval: $badgeCount',
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Center(
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketlinkweb/components/loading.dart';

class Customers extends StatefulWidget {
  const Customers({super.key});

  @override
  State<Customers> createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  Future<List<QueryDocumentSnapshot>> fetchRecentCustomers() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('customers')
        .orderBy('createdAt', descending: true)
        .get();
    return querySnapshot.docs;
  }

  Future<int> ordersCount(String customerId) async {
    final count = await FirebaseFirestore.instance
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .where('status', isEqualTo: 'delivered')
        .get();

    return count.docs.length;
  }

  Future<double> calculateTotalSales(String customerId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .where('status', isEqualTo: 'delivered')
        .get();

    double totalSales = 0.0;

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final payment = data['totalPayment'];

      if (payment != null && payment is num) {
        totalSales += payment.toDouble();
      }
    }

    return totalSales;
  }

  void showCustomer(BuildContext context, Map<String, dynamic> customer) {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) {
        return FadeInUp(
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              width: size.width * 0.55,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showFullImage(context, customer['imageUrl']);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            customer['profilePicture'] ?? '/images/profile.png',
                            height: size.height * 0.5,
                            width: size.width * 0.3,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported,
                                    size: 100),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${customer['firstName'] ?? ''} ${customer['lastName'] ?? ''}'
                                            .trim()
                                            .isEmpty
                                        ? 'No Name'
                                        : '${customer['firstName'] ?? ''} ${customer['lastName'] ?? ''}'
                                            .trim(),
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    customer['disabled']
                                        ? IconButton(
                                            tooltip: 'Enable',
                                            iconSize: 40,
                                            icon: const Icon(Icons.check,
                                                color: Colors.green),
                                            onPressed: () => enableCustomer(
                                                context, customer, () {
                                              setState(() {});
                                            }),
                                          )
                                        : IconButton(
                                            tooltip: 'Disable',
                                            iconSize: 40,
                                            icon: const Icon(Icons.block,
                                                color: Colors.red),
                                            onPressed: () => disableCustomer(
                                                context, customer, () {
                                              setState(() {});
                                            }),
                                          ),
                                    IconButton(
                                      tooltip: 'Delete',
                                      iconSize: 40,
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          deleteCustomer(context, customer, () {
                                        setState(() {});
                                      }),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Created At: ${formatTimestamp(customer['createdAt'])}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Email: ${customer['email']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Status: ${customer['disabled'] ? 'Disabled' : 'Active'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Contact Number: ${customer['contactNumber'] ?? 'No Number'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Address: ${customer['address'] ?? 'No Address'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text('Products Ordered: '),
                                FutureBuilder<int>(
                                  future: ordersCount(customer['id']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text('Loading...');
                                    } else if (snapshot.hasError) {
                                      return const Text('Error');
                                    } else {
                                      return Text('${snapshot.data}');
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text('Total Sales: '),
                                FutureBuilder<double>(
                                  future: calculateTotalSales(customer['id']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text('Loading sales...');
                                    } else if (snapshot.hasError) {
                                      return const Text('Error fetching sales');
                                    } else {
                                      return Text(
                                        '₱${snapshot.data!.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 16),
                                      );
                                    }
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Close',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void deleteCustomer(BuildContext context, Map<String, dynamic> customer,
      VoidCallback onDelete) async {
    bool confirmDelete = await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Deletion"),
            content: Text(
                "Are you sure you want to delete  ${customer['firstName']} ${customer['lastName']}?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmDelete) {
      try {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(customer['id'])
            .delete();

        if (context.mounted) {
          Navigator.pop(context);
          onDelete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Customer deleted successfully")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting customer: $e")),
          );
        }
      }
    }
  }

  void disableCustomer(BuildContext context, Map<String, dynamic> customer,
      VoidCallback onDisable) async {
    bool? confirmDisable = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Disable"),
        content: Text(
            "Are you sure you want to disable ${customer['firstName']} ${customer['lastName']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Disable", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDisable == true) {
      try {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(customer['id'])
            .update({'disabled': true});

        if (context.mounted) {
          Navigator.pop(context);
          onDisable();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Customer disabled successfully")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error disabling customer: $e")),
          );
        }
      }
    }
  }

  void enableCustomer(BuildContext context, Map<String, dynamic> customer,
      VoidCallback onDisable) async {
    bool? confirmDisable = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Enable"),
        content: Text(
            "Are you sure you want to enable ${customer['firstName']} ${customer['lastName']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Enable", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirmDisable == true) {
      try {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(customer['id'])
            .update({'disabled': false});

        if (context.mounted) {
          Navigator.pop(context);
          onDisable();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Customer enable successfully")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error enabling customer: $e")),
          );
        }
      }
    }
  }

  void showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.white),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "No Login Data";

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return "Invalid Date";
    }

    return DateFormat('MMMM d, y • h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 239, 249),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FadeInLeft(
                  child: Text(
                    'Customers',
                    style: TextStyle(
                        fontSize: isMobile ? 20 : 50,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: fetchRecentCustomers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Loading());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching customers'));
                }

                final customers = snapshot.data
                        ?.map((doc) => {
                              'id': doc.id,
                              ...doc.data() as Map<String, dynamic>,
                            })
                        .where((customer) {
                      final firstName =
                          customer['firstName']?.toLowerCase() ?? '';
                      final lastName =
                          customer['lastName']?.toLowerCase() ?? '';
                      final fullName = '$firstName $lastName';
                      return fullName.contains(searchQuery.toLowerCase());
                    }).toList() ??
                    [];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 4,
                    ),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return FadeInUp(
                        child: GestureDetector(
                          onTap: () => showCustomer(context, customer),
                          child: SizedBox(
                            height: 100,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    customer['profilePicture'] != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              customer['profilePicture']!,
                                              height: isMobile ? 70 : 100,
                                              width: isMobile ? 70 : 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(
                                                      Icons.account_circle),
                                            ),
                                          )
                                        : Icon(
                                            Icons.account_circle,
                                            size: isMobile ? 70 : 100,
                                          ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${customer['firstName'] ?? ''} ${customer['lastName'] ?? ''}'
                                                    .trim()
                                                    .isEmpty
                                                ? 'No Name'
                                                : '${customer['firstName'] ?? ''} ${customer['lastName'] ?? ''}'
                                                    .trim(),
                                            style: TextStyle(
                                              fontSize: isMobile ? 17 : 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            customer['email'] ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: isMobile ? 12 : 15,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Last Login: ${formatTimestamp(customer['dateLastLogin'])}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: isMobile ? 12 : 15,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

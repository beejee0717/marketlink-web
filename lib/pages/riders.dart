import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketlinkweb/components/loading.dart';

class Riders extends StatefulWidget {
  const Riders({super.key});

  @override
  State<Riders> createState() => _RidersState();
}

class _RidersState extends State<Riders> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  Future<List<QueryDocumentSnapshot>> fetchRecentRiders() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('riders')
        .orderBy('createdAt', descending: true)
        .get();
    return querySnapshot.docs;
  }


Future<int> riderDeliveryCount(String riderId) async{
final deliveryCount = await FirebaseFirestore.instance
.collection('orders').where('riderId', isEqualTo: riderId)
.where('status', isEqualTo: 'delivered').get();

return deliveryCount.docs.length;
}



  void showRider(BuildContext context, Map<String, dynamic> rider) {
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
                          showFullImage(context, rider['imageUrl']);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            rider['profilePicture'] ?? '/images/profile.png',
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
                                    '${rider['firstName'] ?? ''} ${rider['lastName'] ?? ''}'
                                            .trim()
                                            .isEmpty
                                        ? 'No Name'
                                        : '${rider['firstName'] ?? ''} ${rider['lastName'] ?? ''}'
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
                                    rider['disabled']
                                        ? IconButton(
                                            tooltip: 'Enable',
                                            iconSize: 40,
                                            icon: const Icon(Icons.check,
                                                color: Colors.green),
                                            onPressed: () => enableRider(
                                                context, rider, () {
                                              setState(() {});
                                            }),
                                          )
                                        : IconButton(
                                            tooltip: 'Disable',
                                            iconSize: 40,
                                            icon: const Icon(Icons.block,
                                                color: Colors.red),
                                            onPressed: () => disableRider(
                                                context, rider, () {
                                              setState(() {});
                                            }),
                                          ),
                                    IconButton(
                                      tooltip: 'Delete',
                                      iconSize: 40,
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          deleteRider(context, rider, () {
                                        setState(() {});
                                      }),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 5),
                               Row(
                              children: [
                            GestureDetector(
  onTap: () {
    showFullImage(context, rider['imageID']);
  },
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.blue, 
      borderRadius: BorderRadius.circular(12), 
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: const Text(
      'Show ID',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)
   , const  SizedBox(width: 10),   GestureDetector(
  onTap: () {
    showFullImage(context, rider['imageSelfie']);
  },
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.yellow, 
      borderRadius: BorderRadius.circular(12), 
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: const Text(
      'Show Selfie',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)

                               ],
                            ),
                            rider['approved']
                                ? const Text(
                                    'Approved',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green,
                                    ),
                                  )
                                : const Text(
                                    'Not Approved Yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red,
                                    ),
                                  ),
                            const SizedBox(height: 10),
                            Text(
                              'Created At: ${formatTimestamp(rider['createdAt'])}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Email: ${rider['email']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Status: ${rider['disabled'] ? 'Disabled' : 'Active'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Contact Number: ${rider['contactNumber'] ?? 'No Number'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            if(rider['approved']==true)...[
Text('Address: ${rider['address'] ?? 'No address'}'),
                                   const SizedBox(height: 10),
 Row(
   children: [
    const Text('Products Delivered: '),
    
     FutureBuilder<int>(
      future: riderDeliveryCount(rider['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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

                            ]
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

  void deleteRider(BuildContext context, Map<String, dynamic> rider,
      VoidCallback onDelete) async {
    bool confirmDelete = await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Deletion"),
            content: Text(
                "Are you sure you want to delete  ${rider['firstName']} ${rider['lastName']}?"),
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
            .collection('riders')
            .doc(rider['id'])
            .delete();

        if (context.mounted) {
          Navigator.pop(context);
          onDelete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Rider deleted successfully")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting rider: $e")),
          );
        }
      }
    }
  }

  void disableRider(BuildContext context, Map<String, dynamic> rider,
      VoidCallback onDisable) async {
    bool? confirmDisable = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Disable"),
        content: Text(
            "Are you sure you want to disable ${rider['firstName']} ${rider['lastName']}?"),
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
            .collection('riders')
            .doc(rider['id'])
            .update({'disabled': true});

        if (context.mounted) {
          Navigator.pop(context);
          onDisable();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Rider disabled successfully")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error disabling rider: $e")),
          );
        }
      }
    }
  }

  void enableRider(BuildContext context, Map<String, dynamic> rider,
      VoidCallback onDisable) async {
    bool? confirmDisable = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Enable"),
        content: Text(
            "Are you sure you want to enable ${rider['firstName']} ${rider['lastName']}?"),
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
            .collection('riders')
            .doc(rider['id'])
            .update({'disabled': false});

        if (context.mounted) {
          Navigator.pop(context);
          onDisable();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Rider enable successfully")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error enabling Rider: $e")),
          );
        }
      }
    }
  }

void showFullImage(BuildContext context, String? imageUrl) {
  if (imageUrl == null || imageUrl.trim().isEmpty) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No Image'),
          content: const Text('No image uploaded.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return;
  }

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
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
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

  void approval(BuildContext context, Map<String, dynamic> rider,
      VoidCallback onApprove) {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Approve Rider"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: "Click to view full image",
              child: GestureDetector(
                onTap: () => showFullImage(context, rider['imageID']),
                child: rider['imageID'] != null && rider['imageID'].isNotEmpty
                    ? Image.network(
                        rider['imageID'],
                        width: size.width * .5,
                        height: size.height * .5,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No Image Provided'),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('riders')
                    .doc(rider['id'])
                    .update({'approved': true});

                if (context.mounted) {
                  Navigator.pop(context);
                  onApprove();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Rider approved successfully")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error approving rider: $e")),
                  );
                }
              }
            },
            child: const Text("Approve", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FadeInLeft(
                child: Text(
                  'Riders',
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
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: fetchRecentRiders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Loading());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching rider'));
                }

                final riders = snapshot.data
                        ?.map((doc) => {
                              'id': doc.id,
                              ...doc.data() as Map<String, dynamic>,
                            })
                        .where((rider) {
                      final firstName =
                          rider['firstName']?.toLowerCase() ?? '';
                      final lastName = rider['lastName']?.toLowerCase() ?? '';
                      final fullName = '$firstName $lastName';
                      return fullName.contains(searchQuery.toLowerCase());
                    }).toList() ??
                    [];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 4,
                    ),
                    itemCount: riders.length,
                    itemBuilder: (context, index) {
                      final rider = riders[index];
                      return FadeInUp(
                        child: GestureDetector(
                          onTap: () => showRider(context, rider),
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
                                    rider['profilePicture'] != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              rider['profilePicture']!,
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
                                            '${rider['firstName'] ?? ''} ${rider['lastName'] ?? ''}'
                                                    .trim()
                                                    .isEmpty
                                                ? 'No Name'
                                                : '${rider['firstName'] ?? ''} ${rider['lastName'] ?? ''}'
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
                                            rider['email'] ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: isMobile ? 12 : 15,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Last Login: ${formatTimestamp(rider['dateLastLogin'])}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: isMobile ? 12 : 15,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    rider['approved']
                                        ? const SizedBox.shrink()
                                        :Text('Need Approval',  style: TextStyle(
                                                fontSize: isMobile ? 12 : 15,
                                                color: Colors.red),)
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
        ),
      ],
    ),
  );
}}
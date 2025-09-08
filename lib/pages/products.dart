import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketlinkweb/components/loading.dart';

import '../components/components.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  ProductsState createState() => ProductsState();
}

class ProductsState extends State<Products> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  Future<List<QueryDocumentSnapshot>> fetchRecentProducts() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .orderBy('dateCreated', descending: true)
        .get();
    return querySnapshot.docs;
  }

  void showProduct(BuildContext context, Map<String, dynamic> product) {
    final size = MediaQuery.of(context).size;
    final String productId = product['id'] ?? '';

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
              width: size.width * 0.75,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showFullImage(context, product['imageUrl']);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            product['imageUrl'] ?? '',
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
                                    product['productName'] ?? 'No Name',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      deleteProduct(context, product, () {
                                    setState(() {});
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Category: ${product['category'] ?? 'No Category'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              product['description'] ?? 'No Description',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Material: ${product['materials'] != null && product['materials'].isNotEmpty ? product['materials'] : 'Not Specified'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Stock: ${product['stock']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Pickup Location: ${product['pickupLocation']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Reviews:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              height: 150, 
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('products')
                                    .doc(productId)
                                    .collection('reviews')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                        child: Text('No reviews yet.'));
                                  }
                                  final reviews = snapshot.data!.docs;
                                  return ListView.builder(
                                    itemCount: reviews.length,
                                    itemBuilder: (context, index) {
                                      final review = reviews[index];
                                      return ListTile(
                                        title: Text(review['comment'] ?? ''),
                                        subtitle: Row(
                                          children: List.generate(
                                            review['stars'] ?? 0,
                                            (index) => const Icon(Icons.star,
                                                color: Colors.amber, size: 16),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₱${product['price']}',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
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


void deleteProduct(BuildContext context, Map<String, dynamic> product,
    VoidCallback onDelete) async {
  bool confirmDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text(
              "Are you sure you want to delete '${product['productName']}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ??
      false;

  if (confirmDelete == true) {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference productDoc =
          firestore.collection('products').doc(product['id']);

      await deleteSubcollections(productDoc);

      await productDoc.delete();

      if (context.mounted) {
        Navigator.pop(context);
        onDelete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product deleted successfully")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting product: $e")),
        );
      }
    }
  }
}

Future<void> deleteSubcollections(DocumentReference docRef) async {
  // FirebaseFirestore firestore = FirebaseFirestore.instance;

  // var subcollections = await docRef.collectionGroup(docRef.id).get();

  // for (var subcollection in subcollections.docs) {
   
  //   var subDocs = await firestore
  //       .collection(docRef.path + "/" + subcollection.id)
  //       .get();

  //   for (var subDoc in subDocs.docs) {
  //     await deleteSubcollections(subDoc.reference);
  //     await subDoc.reference.delete();
  //   }
  // }
}
  Future<Map<String, dynamic>> getProductRating(String productId) async {
  try {
    CollectionReference reviewsRef = FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .collection('reviews');

    QuerySnapshot querySnapshot = await reviewsRef.get();

    if (querySnapshot.docs.isEmpty) {
      return {'averageRating': 0.0, 'totalReviews': 0};
    }

    double totalStars = 0;
    int totalReviews = querySnapshot.docs.length;

    for (var doc in querySnapshot.docs) {
      totalStars += (doc['stars'] as num).toDouble();
    }

    double averageRating = totalStars / totalReviews;

    return {'averageRating': averageRating, 'totalReviews': totalReviews};
  } catch (e) {
   return {'averageRating': 0.0, 'totalReviews': 0};
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
                  'Products',
                  style: TextStyle(
                      fontSize: isMobile ? 20 : 50,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [refreshButton((){setState(() {
                    
                  });}),
                 const SizedBox(width: 10,),
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
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<QueryDocumentSnapshot>>(
            future: fetchRecentProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Loading());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error fetching products'));
              }

              final products = snapshot.data
                      ?.map((doc) => {
                            'id': doc.id,
                            ...doc.data() as Map<String, dynamic>,
                          })
                      .where((product) {
                    final name = product['productName']?.toLowerCase() ?? '';
                    return name.contains(searchQuery);
                  }).toList() ??
                  [];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 2 : 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return FadeInUp(
                      child: GestureDetector(
                        onTap: () => showProduct(context, product),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10)),
                                child: Image.network(
                                  product['imageUrl'] ?? '',
                                  height: isMobile ? 100 : 350,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error,
                                          stackTrace) =>
                                      const Icon(Icons.image_not_supported),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['productName'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    FutureBuilder<Map<String, dynamic>>(
                                      future: getProductRating(product['id']),
                                      builder: (context, ratingSnapshot) {
                                        if (ratingSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox(
                                            height: 20,
                                            width: 50,
                                            child: LinearProgressIndicator(),
                                          );
                                        }
                                        if (ratingSnapshot.hasError) {
                                          return const Text('Error');
                                        }

                                        double averageRating =
                                            ratingSnapshot.data?[
                                                    'averageRating'] ??
                                                0.0;
                                        int totalReviews =
                                            ratingSnapshot.data?[
                                                    'totalReviews'] ??
                                                0;

                                        return Row(
                                          children: [
                                       const     Icon(Icons.star,
                                                color: Colors.amber, size: 20),
                                            if (averageRating >= 1)
                                              const Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 20),
                                            if (averageRating >= 2)
                                            const  Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 20),
                                            if (averageRating >= 3)
                                             const Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 20),
                                            if (averageRating >= 4)
                                             const Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 20),
                                            if (averageRating > 0 &&
                                                averageRating < 5)
                                              const Icon(Icons.star_half,
                                                  color: Colors.amber,
                                                  size: 20),
                                            const SizedBox(width: 5),
                                            Text(
                                              '($totalReviews)',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700]),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      product['description'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      '₱${product['price']}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
 }}
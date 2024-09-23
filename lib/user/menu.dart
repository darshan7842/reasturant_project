import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserMenuScreen extends StatefulWidget {
  @override
  _UserMenuScreenState createState() => _UserMenuScreenState();
}

class _UserMenuScreenState extends State<UserMenuScreen> {
  List<PopularItem> popularItems = [];
  Map<String, int> itemQuantities = {}; // To track quantities of items

  @override
  void initState() {
    super.initState();
    _fetchPopularItems();
  }

  Future<void> _fetchPopularItems() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('popularItems').get();
    setState(() {
      popularItems = snapshot.docs
          .map((doc) =>
          PopularItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: popularItems.isEmpty
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: popularItems.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              child: Column(
                children: [
                  Expanded(
                    child: popularItems[index].image.startsWith('assets/')
                        ? Image.asset(
                        popularItems[index].image, fit: BoxFit.cover)
                        : Image.file(File(popularItems[index].image)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          popularItems[index].name,
                          style: TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Rs.${popularItems[index].price}",
                          style: TextStyle(color: Colors.black87,
                              fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                _updateQuantity(popularItems[index].docId, -1);
                              },
                            ),
                            Text(
                              '${itemQuantities[popularItems[index].docId] ?? 0}',
                              style: TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                _updateQuantity(popularItems[index].docId, 1);
                              },
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _orderItem(popularItems[index]);
                          },
                          child: Text('Order'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _updateQuantity(String itemId, int change) {
    setState(() {
      itemQuantities[itemId] = (itemQuantities[itemId] ?? 0) + change;
      // Ensure the quantity doesn't go below zero
      if (itemQuantities[itemId]! < 0) {
        itemQuantities[itemId] = 0;
      }
    });
  }

  Future<void> _orderItem(PopularItem item) async {
    int quantity = itemQuantities[item.docId] ?? 0;
    if (quantity > 0) {
      await FirebaseFirestore.instance.collection('userOrders').add({
        'itemName': item.name,
        'price': item.price,
        'image': item.image,
        'quantity': quantity,
        'orderTime': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${item.name} ordered! Quantity: $quantity"))
      );
      _updateQuantity(item.docId, -quantity); // Reset quantity after ordering
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Select quantity before ordering!"))
      );
    }
  }
}

// PopularItem class remains unchanged
class PopularItem {
  String name;
  double price;
  String image;
  String docId;

  PopularItem({
    required this.name,
    required this.price,
    required this.image,
    required this.docId,
  });

  factory PopularItem.fromMap(Map<String, dynamic> map, String docId) {
    return PopularItem(
      name: map['name'],
      price: map['price'],
      image: map['image'],
      docId: docId,
    );
  }
}

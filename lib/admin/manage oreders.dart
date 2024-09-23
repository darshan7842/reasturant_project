import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'billingpage.dart';

class ManageOrders extends StatefulWidget
{
  @override
  _ManageOrdersState createState() => _ManageOrdersState();
}

class _ManageOrdersState extends State<ManageOrders> {
  List<OrderItem> adminOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchAdminOrders();
  }

  Future<void> _fetchAdminOrders() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('userOrders').get();
      setState(() {
        adminOrders = snapshot.docs
            .map((doc) => OrderItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching orders: $e")));
    }
  }

  double _calculateTotalPrice() {
    double total = 0;
    for (var order in adminOrders) {
      total += order.price * order.quantity; // Calculate total price
    }
    return total;
  }

  void _openBillingPage(String orderId, String itemName, double price) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillingPage(orderId: orderId, itemName: itemName, price: price),
      ),
    );
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 10),
        child: adminOrders.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Total Price: Rs.${_calculateTotalPrice().toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: adminOrders.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Container(
                      width: 40,
                      child: adminOrders[index].image.isNotEmpty
                          ? (adminOrders[index].image.startsWith('assets/')
                          ? Image.asset(adminOrders[index].image, fit: BoxFit.cover)
                          : Image.file(File(adminOrders[index].image), fit: BoxFit.cover))
                          : Icon(Icons.fastfood), // Placeholder if no image is provided
                    ),
                    title: Text(adminOrders[index].itemName),
                    subtitle: Text(
                      "Rs.${adminOrders[index].price} x ${adminOrders[index].quantity} items",
                    ),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            adminOrders[index].orderTime.toDate().toString(),
                            overflow: TextOverflow.ellipsis, // Handle overflow
                            maxLines: 1, // Limit to one line
                          ),
                        ),
                        SizedBox(height: 4),
                        Flexible(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _openBillingPage(
                                adminOrders[index].itemId,
                                adminOrders[index].itemName,
                                adminOrders[index].price,
                              );
                            },
                            label: Text("Complete"),
                            icon: Icon(Icons.check, color: Colors.white, size: 19),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderItem {
  String itemId;
  String itemName;
  double price;
  String image;
  Timestamp orderTime;
  int quantity;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.image,
    required this.orderTime,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map, String docId) {
    return OrderItem(
      itemId: docId,
      itemName: map['itemName'],
      price: map['price'],
      image: map['image'],
      orderTime: map['orderTime'],
      quantity: map['quantity'] ?? 1, // Default to 1 if not provided
    );
  }
}

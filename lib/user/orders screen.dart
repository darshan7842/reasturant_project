import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderItem> userOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchUserOrders();
  }

  Future<void> _fetchUserOrders() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('userOrders').get();
      setState(() {
        userOrders = snapshot.docs
            .map((doc) => OrderItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching orders: $e")));
    }
  }

  double _calculateTotalAmount() {
    double total = 0;
    for (var order in userOrders) {
      total += order.price * order.quantity;
    }
    return total;
  }

  Future<void> _clearOrders() async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var order in userOrders) {
        batch.delete(FirebaseFirestore.instance.collection('userOrders').doc(order.itemId));
      }

      await batch.commit();
      setState(() {
        userOrders.clear(); // Clear local list
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All orders cleared!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error clearing orders: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Total Amount: Rs.${_calculateTotalAmount().toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          userOrders.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: userOrders.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Container(
                    width: 50,
                    child: userOrders[index].image.isNotEmpty
                        ? (userOrders[index].image.startsWith('assets/')
                        ? Image.asset(userOrders[index].image, fit: BoxFit.cover)
                        : Image.file(File(userOrders[index].image), fit: BoxFit.cover))
                        : Icon(Icons.fastfood), // Placeholder if no image is provided
                  ),
                  title: Text(userOrders[index].itemName),
                  subtitle: Text("Rs.${userOrders[index].price} x ${userOrders[index].quantity}"),
                  trailing: Text(DateFormat('yyyy-MM-dd – kk:mm').format(userOrders[index].orderTime.toDate())),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _showPaymentConfirmationDialog();
            },
            child: Text("Pay"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Payment"),
          content: Text("Are you sure you want to proceed with the payment?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _clearOrders();
                Navigator.of(context).pop();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
}

class OrderItem {
  String itemId;
  String itemName;
  double price;
  String image;
  Timestamp orderTime;
  int quantity; // New field for quantity

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.image,
    required this.orderTime,
    required this.quantity, // Initialize quantity
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

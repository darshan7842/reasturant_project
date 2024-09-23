import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillingPage extends StatefulWidget {
  final String orderId;
  final String itemName;
  final double price;

  BillingPage({required this.orderId, required this.itemName, required this.price});

  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  TextEditingController _amountController = TextEditingController();
  bool _isCollecting = false;

  Future<void> _collectAmount() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter the amount")),
      );
      return;
    }

    setState(() {
      _isCollecting = true;
    });

    try {
      // Mark the order as collected and delete it from Firebase
      await FirebaseFirestore.instance.collection('userOrders').doc(widget.orderId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Amount collected successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BillPage(
            itemName: widget.itemName,
            price: widget.price,
            collectedAmount: double.tryParse(_amountController.text) ?? widget.price,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error collecting amount: $e")),
      );
    } finally {
      setState(() {
        _isCollecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Collect Payment for ${widget.itemName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Item: ${widget.itemName}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "Price: Rs.${widget.price}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Collected Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isCollecting
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _collectAmount,
              child: Text("Collect Amount"),
            ),
          ],
        ),
      ),
    );
  }
}

class BillPage extends StatelessWidget {
  final String itemName;
  final double price;
  final double collectedAmount;

  BillPage({
    required this.itemName,
    required this.price,
    required this.collectedAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bill"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Receipt",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Item: $itemName",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "Price: Rs.$price",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "Collected Amount: Rs.$collectedAmount",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

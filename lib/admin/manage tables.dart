import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../order_model.dart';
import '../table_model.dart';

class ManageTables extends StatefulWidget {
  const ManageTables({Key? key}) : super(key: key);

  @override
  State<ManageTables> createState() => _ManageTablesState();
}

class _ManageTablesState extends State<ManageTables> {
  List<TableModel> _tables = [];
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadTableStatusAndOrders();
  }

  Future<void> _loadTableStatusAndOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _tables = List.generate(10, (index) {
        String tableStatus =
            prefs.getString('table_$index') ?? TableStatus.Available.toString();
        return TableModel(
          id: index + 1,
          name: "Table ${index + 1}",
          capacity: (index % 3 + 2) * 2,
          status: TableStatus.values.firstWhere((status) => status.toString() == tableStatus),
        );
      });
    });

    List<String>? orderList = prefs.getStringList('orders');
    if (orderList != null) {
      setState(() {
        _orders = orderList.map((orderJson) => Order.fromJson(jsonDecode(orderJson))).toList();
      });
    }
  }

  Future<void> _saveTableStatusAndOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < _tables.length; i++) {
      prefs.setString('table_$i', _tables[i].status.toString());
    }

    List<String> orderList = _orders.map((order) => jsonEncode(order.toJson())).toList();
    await prefs.setStringList('orders', orderList);
  }

  void _bookTableForGuest(int tableId) {
    String guestName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Book Table for Guest'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Guest Name'),
            onChanged: (value) {
              guestName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (guestName.isNotEmpty) {
                  Order newOrder = Order(
                    tableId: tableId,
                    foodItems: [],
                    userName: guestName,
                    totalPrice: 0.0,
                  );

                  setState(() {
                    var table = _tables.firstWhere((table) => table.id == tableId);
                    table.status = TableStatus.Booked;
                    _orders.add(newOrder);
                  });
                  _saveTableStatusAndOrders();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Book'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _cancelReservation(int tableId) {
    setState(() {
      var table = _tables.firstWhere((table) => table.id == tableId);
      table.status = TableStatus.Available;
      _orders.removeWhere((order) => order.tableId == tableId);
    });
    _saveTableStatusAndOrders();
  }

  void _markReservationAsDone(int tableId) {
    setState(() {
      var table = _tables.firstWhere((table) => table.id == tableId);
      table.status = TableStatus.Available;
      _orders.removeWhere((order) => order.tableId == tableId);
    });
    _saveTableStatusAndOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Tables'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _tables.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    color: _tables[index].status == TableStatus.Booked ? Colors.grey[300] : Colors.white,
                    child: ListTile(
                      title: Text(_tables[index].name),
                      subtitle: Text('Capacity: ${_tables[index].capacity} - Status: ${_tables[index].status.toString().split('.').last}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_tables[index].status == TableStatus.Available) ...[
                            ElevatedButton(
                              onPressed: () => _bookTableForGuest(_tables[index].id),
                              child: Text('Book'),
                            ),
                          ],
                          if (_tables[index].status == TableStatus.Booked) ...[
                            ElevatedButton(
                              onPressed: () => _cancelReservation(_tables[index].id),
                              child: Text('Cancel'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Current Booked tables',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Order by ${_orders[index].userName}'),
                    subtitle: Text('Table ID: ${_orders[index].tableId}'),
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

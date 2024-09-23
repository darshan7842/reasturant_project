import 'package:flutter/material.dart';
import 'package:reasturant_project/user/user%20book%20a%20table.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../loginscreen.dart';
import '../order_model.dart';
import '../table_model.dart';
import 'menu.dart';
import 'orders screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  List<TableModel> tables = [
    TableModel(id: 1, name: 'Table 1', capacity: 4, status: TableStatus.Available),
    TableModel(id: 2, name: 'Table 2', capacity: 2, status: TableStatus.Available),
    TableModel(id: 3, name: 'Table 3', capacity: 6, status: TableStatus.Reserved),
    TableModel(id: 4, name: 'Table 4', capacity: 10, status: TableStatus.Available),
    TableModel(id: 5, name: 'Table 5', capacity: 5, status: TableStatus.Available),
    TableModel(id: 6, name: 'Table 6', capacity: 8, status: TableStatus.Available),
    TableModel(id: 7, name: 'Table 7', capacity: 4, status: TableStatus.Available),
    TableModel(id: 8, name: 'Table 8', capacity: 2, status: TableStatus.Reserved),
    TableModel(id: 9, name: 'Table 9', capacity: 6, status: TableStatus.Available),
    TableModel(id: 10, name: 'Table 10', capacity: 10, status: TableStatus.Available),
    TableModel(id: 11, name: 'Table 11', capacity: 5, status: TableStatus.Available),
    TableModel(id: 12, name: 'Table 12', capacity: 8, status: TableStatus.Reserved),
  ];

  static List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeScreen(),
      UserMenuScreen(),
      OrdersScreen(),
    ];
  }

  void _handleOrder(Order order) {
    print("Order placed for table ${order.tableId} by ${order.userName}");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () {
                _logout(); // Call the logout function
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Dashboard'),
        backgroundColor: Colors.greenAccent[400],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.greenAccent[100],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/circleavtar.jpg'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Darshan',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'darsh@gmail.com',
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.menu_book),
              title: Text('View Menu'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserMenuScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text('Your Orders'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrdersScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart),
              title: Text('Book a Table'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallingDetailsPage(

                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/reastaurant.png'),
          SizedBox(height: 20),
          Text(
            'Welcome to Our Restaurant!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

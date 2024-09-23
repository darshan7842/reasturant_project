import 'package:flutter/material.dart';
import 'package:reasturant_project/admin/manage%20tables.dart';

import 'manage oreders.dart';
import 'manage popular iteams.dart';

class DashboardHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Manage Popular Items'),
            leading: Icon(Icons.fastfood),
            trailing: Icon(Icons.arrow_forward),
            tileColor: Colors.greenAccent[100],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManagePopularItems()),
              );
            },
          ),
        ),
        Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('View Orders'),
            leading: Icon(Icons.receipt_long),
            trailing: Icon(Icons.arrow_forward),
            tileColor: Colors.greenAccent[100],

            onTap: ()
            {
             Navigator.push(context, MaterialPageRoute(builder: ((context)=>ManageOrders())));
            },
          ),
        ),
        Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Manage Tables'),
            leading: Icon(Icons.table_chart),
            trailing: Icon(Icons.arrow_forward),
            tileColor: Colors.greenAccent[100],

            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageTables()),
              );
            },
          ),
        ),
      ],
    );
  }
}

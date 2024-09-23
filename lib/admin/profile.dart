import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold
      (
      body: Padding
        (
        padding: EdgeInsets.all(16.0),
        child: Column
          (
          children:
          [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/circleavtar.jpg'),
            ),
            SizedBox(height: 20),
            Text(
              'Darshan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'darshan@gmail.com',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 40),

            ListTile(
              leading: Icon(Icons.person),
              title: Text('Name'),
              subtitle: Text('Darshan'),
            ),

            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
              subtitle: Text('darshan@gmail.com'),
            ),

            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone'),
              subtitle: Text('+91 1234567890'),
            ),
          ],
        ),
      ),
    );
  }
}
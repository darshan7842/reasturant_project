// The LoginScreen code you provided earlier remains the same but ensure
// to check if the mobile number is exactly matching the document ID saved during registration.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reasturant_project/register_screen.dart';
import 'package:reasturant_project/user/userdashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin/admindashboard.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _mobilenumber;
  String? _password;
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Form', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.greenAccent[100],
      ),
      body: Stack(
        children: [
          Lottie.asset('assets/Animation - 1726681949387.json', width: double.infinity, height: double.infinity, fit: BoxFit.cover),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        hintText: 'Enter mobile number',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.greenAccent[70],
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a mobile number';
                        }
                        if (value.length != 10) {
                          return 'Mobile number must be 10 digits';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _mobilenumber = value;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter password',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.greenAccent[70],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                      obscureText: true,
                      onSaved: (value) {
                        _password = value;
                      },
                    ),
                    SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Log in', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[100],
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Create an account', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupScreen()));
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _login();
    }
  }

  Future<void> _login() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Check for admin credentials
    if (_mobilenumber == "1234567890" && _password == "1234") {
      sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setBool('isLoggedIn', true);
      await sharedPreferences.setString('role', 'admin');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
      return;
    }

    // Check for user credentials in Firestore
    var userDoc = await _firestore.collection('users').doc(_mobilenumber).get();

    if (userDoc.exists) {
      var userData = userDoc.data()!;
      if (userData['password'] == _password) {
        sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setBool('isLoggedIn', true);
        await sharedPreferences.setString('role', 'user');
        await sharedPreferences.setString('mob', _mobilenumber!);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserDashboard()));
      } else {
        final snackbar = SnackBar(content: Text('Incorrect password'));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    } else {
      final snackbar = SnackBar(content: Text('User not found'));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<void> checkLogin() async {
    sharedPreferences = await SharedPreferences.getInstance();
    bool isLoggedIn = sharedPreferences.getBool('isLoggedIn') ?? false;
    String? role = sharedPreferences.getString('role');

    if (isLoggedIn && role == 'admin') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
    } else if (isLoggedIn && role == 'user') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserDashboard()));
    }
  }
}

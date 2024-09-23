import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:reasturant_project/splashscreen.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: AutofillHints.language,
    ),
    home: nextscreen(),
    debugShowCheckedModeBanner: false,
  ));
}

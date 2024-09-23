import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'loginscreen.dart';

class nextscreen extends StatefulWidget
{
  const nextscreen({super.key});

  @override
  State<nextscreen> createState() => nextscreenState();
}

class nextscreenState extends State<nextscreen>
{

  @override
  void initState()
  {
    // TODO: implement initState
    super.initState();

    Timer
      (
        Duration(seconds: 5), () =>
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()))
    );
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
      (
      body: Center
        (
          child: Lottie.asset
            (
             "assets/Animation - 1726547953231.json"
          )
      ),
    ) ;
  }
}
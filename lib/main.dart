//  dart: ">=3.0.0-0 <4.0.0"
//flutter 3.10.0


import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_app/views/login_page.dart';

import 'card.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}


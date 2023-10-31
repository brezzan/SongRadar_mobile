import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:songradar/login.dart';
import 'dart:convert';
import 'dart:core';
import 'package:songradar/signup.dart';
import 'package:songradar/signup.dart';

void main() {
  runApp(const SongRadar());
}

class SongRadar extends StatelessWidget {
  const SongRadar({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
        routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => LoginPage(),
        '/signup': (BuildContext context) => SignUpPage(), // Pass the 'mail' parameter

      },
    );
  }
}


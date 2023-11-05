import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';
import 'package:songradar/sqlHelper.dart';
import 'package:songradar/mainAppPage.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

void main() async {
  /*
  WidgetsFlutterBinding.ensureInitialized();
  //Copy the database from assets to data directory
  await SqlHelper.copyAsset();
*/
  runApp(SongRadar());
}

class SongRadar extends StatelessWidget {
  const SongRadar({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SongRadar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
        routes: <String, WidgetBuilder>{
          '/login': (BuildContext context) => LoginPage(),
          '/signup': (BuildContext context) => SignUpPage(),
          '/mainAppPage':(BuildContext context) => mainAppPage(username: ''),


        },
    );
  }
}


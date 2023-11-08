import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:songradar/addNewAlbum.dart';
import 'package:songradar/addNewSong.dart';
import 'package:songradar/personalPage.dart';
import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';
import 'package:songradar/mainAppPage.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

void main() async {

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
          '/addNewSong':(BuildContext context) => addNewSong(username: ''),
          '/addNewAlbum':(BuildContext context) => addNewAlbum(username: ''),
          '/personalPage':(BuildContext context) => personalPage(username: ''),
        },
    );
  }
}


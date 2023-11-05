import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';



class mainAppPage extends StatefulWidget {

  final String username;
  const mainAppPage({required this.username, Key? key}) : super(key: key);

  @override

  State<mainAppPage> createState() => _mainAppPageState();
}

class _mainAppPageState extends State<mainAppPage> {
  late String username;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    username= '${arguments?['username']}';

      return Scaffold(
        appBar: AppBar(
          title: Text('Welcome, $username'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login', arguments: {});
            },
            child: Text('Log out'),
          ),
        ),
        // Add the rest of your main app UI here
      );
    }
  }



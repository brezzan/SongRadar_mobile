import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'dart:convert';
import 'package:songradar/login.dart';
import 'package:songradar/mainAppPage.dart';

class personalPage extends StatefulWidget {

  final String username;
  const personalPage({required this.username, Key? key}) : super(key: key);


  @override
  State<personalPage> createState() => _personalPageState();
}

class _personalPageState extends State<personalPage> {
  late String username;

  @override

  Widget build(BuildContext context) {
    final arguments =
    ModalRoute
        .of(context)
        ?.settings
        .arguments as Map<String, dynamic>?;
    username = '${arguments?['username']}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Row(
          children: [
            Text('Welcome, $username'),
            SizedBox(
              width: 170,
            ),
            IconButton(
              icon: Icon(
                Icons.logout,
                size: 40,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Log Out ?'),
                      content: Text(
                        'Are you sure you want to log out?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login', arguments: {});
                          },
                          child: Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('No'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

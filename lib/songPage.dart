import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'dart:convert';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';

/*
song info

delete_song function will be here

func not ready
 */

class songPage extends StatefulWidget {
  final int songId, userid;
  final String username;
  const songPage({required this.songId, required this.userid, required this.username, Key? key}) : super(key: key);

  @override
  State<songPage> createState() => _songPageState();
}

class _songPageState extends State<songPage> {
  late String username;
  late int userid; // Corrected variable name to userId
  late int songId;

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userid = int.parse('${arguments?['userid']}');
    songId = int.parse('${arguments?['songId']}');
    username = '${arguments?['username']}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround ,
          children: [
            Flexible(
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/mainAppPage',
                      arguments: {'userid': userid,'username':username});
                },

              ),
            ),
            Flexible(
              child: SizedBox(
                width: 5,
              ),
            ),
            Text('Album Page'),

            Flexible(
              child: SizedBox(
                width: 100,
              ),
            ),
          ],


        ),
      ),
      body:Column(
        children: [

          Text('Song name: '),

        ],
      ),
    );
  }
}
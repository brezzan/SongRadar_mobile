import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'dart:convert';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';

class mainAppPage extends StatefulWidget {
  final String username;
  const mainAppPage({required this.username, Key? key}) : super(key: key);

  @override
  State<mainAppPage> createState() => _mainAppPageState();
}

class _mainAppPageState extends State<mainAppPage> {
  late String username;
  List<Map<String, dynamic>> albums = [];
  List<Map<String, dynamic>> songs = [];

  Future<void> fetchAlbums() async {

    albums = await AuthService().getAlbums();
    print(albums);
    print("----");
    songs = await AuthService().getSongs();
    print(songs);

  }

  @override
  void initState() {
    super.initState();
    fetchAlbums();
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    username = '${arguments?['username']}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Row(
          children: [
            Text('Welcome, $username'),
            SizedBox(
              width: 120,
            ),
            IconButton(
              icon: Icon(
                Icons.music_note,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/addNewSong',
                    arguments: {'username': username});
              },
            ),
            IconButton(
              icon: Icon(
                Icons.person_pin_rounded,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/personalPage', arguments: {'username':username });
              },
            ),
          ],
        ),
      ),
      body: Center(

      ),
      // Add the rest of your main app UI here
    );
  }
}

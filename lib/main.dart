import 'package:flutter/material.dart';
import 'package:songradar/addNewAlbum.dart';
import 'package:songradar/addNewSong.dart';
import 'package:songradar/api.dart';
import 'package:songradar/createPlaylist.dart';
import 'package:songradar/performerPage.dart';
import 'package:songradar/personalPage.dart';
import 'dart:core';
import 'package:songradar/login.dart';
import 'package:songradar/playlistPage.dart';
import 'package:songradar/signup.dart';
import 'package:songradar/mainAppPage.dart';
import 'package:songradar/albumPage.dart';
import 'package:songradar/songPage.dart';
import 'package:songradar/starredSongsPage.dart';

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
          '/mainAppPage':(BuildContext context) => mainAppPage(userid: 0,username:''),
          '/addNewSong':(BuildContext context) => addNewSong(userid: 0,username:''),
          '/addNewAlbum':(BuildContext context) => addNewAlbum(userid: 0,username:''),
          '/personalPage':(BuildContext context) => personalPage(userid:0,username:''),
          '/albumPage':(BuildContext context) => albumPage(albumId: '', userid:0,username:'',),
          '/songPage':(BuildContext context) => songPage(songId:'',userid:0,username:''),
          '/performerPage':(BuildContext context) => performerPage(userid:0,username:'',performers: '',),
          '/createplaylist':(BuildContext context) => createPlaylist(userid:0,username:'',),
          '/playlistPage':(BuildContext context) => playlistPage(userid: 0, username: '', playlistId: 0),
          '/starredSongsPage':(BuildContext context) => starredSongsPage(userid:0,username:'',),
        },
    );
  }
}


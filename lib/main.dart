import 'package:flutter/material.dart';
import 'package:songradar/addNewAlbum.dart';
import 'package:songradar/addNewSong.dart';
import 'package:songradar/api.dart';
import 'package:songradar/performerPage.dart';
import 'package:songradar/personalPage.dart';
import 'dart:core';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';
import 'package:songradar/mainAppPage.dart';
import 'package:songradar/albumPage.dart';
import 'package:songradar/songPage.dart';

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
          '/songPage':(BuildContext context) => songPage(userid:0,username:'',id:'',song:Song(id: '', name: '', album: '', album_id:'', artists: '', artist_ids: '', track_number: 0, disc_number:0 , explicit: true, danceability:0.0, energy:0.0, key: 0, loudness: 0, mode: 0, speechiness: 0.0, acousticness: 0.0, instrumentalness: 0.0, liveness: 0.0, valence: 0.0, tempo: 0.0, duration_ms: 0, time_signature: 0, year: 0, month: 0, day: 0, owner_id: 0)),
          '/performerPage':(BuildContext context) => performerPage(userid:0,username:'',performers: '',),
        },
    );
  }
}


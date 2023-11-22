import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'dart:convert';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';
import 'package:songradar/albumPage.dart';

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

  List<Map<String, dynamic>> to_print_songs = [];
  late Future<List<Map<String, dynamic>>> songs;
  late Future<Map<String, dynamic>> currentUser ;

  Future<void> fetchSongs() async {
    songs = AuthService().getSongs(); // future widget build to see song cards

    to_print_songs = await AuthService().getSongs();
    print("all songs printed:   ");
    print(to_print_songs);
    print("----");
  }

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

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
            Text('Song Page'),
            Flexible(
              child: SizedBox(width: 200),
            ),
            IconButton(
              icon: Icon(
                Icons.home,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/mainAppPage',
                    arguments: {'userid': userid, 'username': username});
              },
            ),
            IconButton(
              icon: Icon(
                Icons.person_pin_rounded,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/personalPage', arguments: {'userid': userid,'username':username});
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child:
        Column(children: <Widget>[
          SizedBox(height: 40),
          Text(
            'Song Details',
            textAlign: TextAlign.center,
          ),
          FutureBuilder(
            future: songs,
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While data is being fetched, you can show a loading indicator
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // If an error occurs during data fetching
                return Text('Error loading songs');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // If no albums are available
                return Text('No songs found');
              } else {
                // Data has been successfully fetched, build the list of AlbumCards
                List<Map<String, dynamic>> songs = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var song in songs)
                        if (song['id'] == songId)
                          SongCard(
                              songName: song['title'].toString(),
                              songPerformers: song['performers'].toString(),
                              songYear: song['year'].toString(),
                              songId: song['id'],
                              songAlbum: song['album_id'],
                              userid: userid,
                              username: username,
                              genre: song['genre']),
                    ],
                  ),
                );
              }
            },
          ),
        ],),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15),
                  shape: BeveledRectangleBorder()),
              onPressed: () {},
              child: Text('Delete Song (Not Implemented Yet)')
          ),
          ),
        ],
      ),
     );
  }
}
class SongCard extends StatelessWidget {
  final String songName, songPerformers, songYear, username, genre;
  final int songId, userid, songAlbum;

  SongCard({
    required this.userid,
    required this.songName,
    required this.songPerformers,
    required this.songYear,
    required this.songAlbum,
    required this.songId,
    required this.username,
    required this.genre,
  });
@override


Widget build(BuildContext context) {
  return Column(
    children: <Widget>[
    Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.all(10.0),
          padding: EdgeInsets.all(30.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
              child: Text(
                'Song Image', // You can replace this with actual album cover widget
                style: TextStyle(fontSize: 12), // Set the desired font size
              ),
            ),
          ),
        SizedBox(
            height: 4.0), // Adjust the spacing between the box and the text
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Song Name :' + songName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Performers :' + songPerformers,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
              Text(
                'Year :' + songYear,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
              Text(
                'Genre :' + genre,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
       ],
      ),
     ],
    );
}
}

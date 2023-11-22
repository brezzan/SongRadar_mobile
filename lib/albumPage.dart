import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'dart:convert';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';

class albumPage extends StatefulWidget {
  final int albumId, userid; // Corrected variable name to userId
  final String username;
  const albumPage(
      {required this.albumId,
      required this.userid,
      required this.username,
      Key? key})
      : super(key: key);

  @override
  State<albumPage> createState() => _albumPageState();
}

class _albumPageState extends State<albumPage> {
  late int userid; // Corrected variable name to userId
  late int albumId;
  late String username;

  List<Map<String, dynamic>> to_print_songs = [];
  late Future<List<Map<String, dynamic>>> songs;
  late Future<Map<String, dynamic>> currentUser ;  // for printing username after getting id in arguments

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
    albumId = int.parse('${arguments?['albumId']}');
    username = '${arguments?['username']}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Row(
          children: [
            Text('Album $albumId'),
            Flexible(
              child: SizedBox(width: 200),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_back,
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
              'Songs in this album',
              textAlign: TextAlign.left,
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
                          if (song['album_id'] == albumId)
                            SongCard(
                              songName: song['title'].toString(),
                              songPerformers: song['performers'].toString(),
                              songYear: song['year'].toString(),
                              songId: song['id'],
                              songAlbum: song['album_id'],
                              userid: userid,
                              username: username),
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
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: BeveledRectangleBorder()),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text(
                              'Are you sure you want to delete this album?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                                child: Text('Delete'),
                                onPressed: () async {
                                  final Map<String, dynamic>deletedAlbum = await AuthService().deleteAlbum(albumId);
                                  print(deletedAlbum);
                                  if (!deletedAlbum.containsKey('error')) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Success'),
                                          content: Text('Album deleted'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.pushReplacementNamed(context, '/mainAppPage',
                                                    arguments: {'userid': userid, 'username': username
                                                    });
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    // Handle deletion error here
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Error'),
                                          content: Text(
                                              'Album could not be deleted'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Delete Album')
              ),
            ),
          ],
        ),
      );
  }
}

class SongCard extends StatelessWidget {
  final String songName, songPerformers, songYear,username;
  final int songId, userid, songAlbum;

  SongCard({
    required this.userid,
    required this.songName,
    required this.songPerformers,
    required this.songYear,
    required this.songAlbum,
    required this.songId,
    required this.username
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/songPage',
            arguments: {'songId': songId, 'userid': userid,'username':username});
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120, // Set the desired height for the box
            width: 120, // Set the desired width for the box
            child: Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
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
          ),
          SizedBox(
              height: 4.0), // Adjust the spacing between the box and the text
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '   ' + songName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '   ' + songPerformers,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

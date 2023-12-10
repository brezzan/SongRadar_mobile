import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'dart:convert';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';
import 'package:songradar/albumPage.dart';

class songPage extends StatefulWidget {
  final int songId, albumId, userid, year;
  final String username, songName, albumName, performers, genre;
  const songPage(
      {required this.songId,
      required this.albumName,
      required this.userid,
      required this.songName,
      required this.albumId,
      required this.year,
      required this.genre,
      required this.performers,
      required this.username,
      Key? key})
      : super(key: key);

  @override
  State<songPage> createState() => _songPageState();
}

class _songPageState extends State<songPage> {
  late String username, songName, albumName, performers, genre;
  late int userid, songId, year, albumId; // Corrected variable name to userId

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userid = int.parse('${arguments?['userid']}');
    songId = int.parse('${arguments?['songId']}');
    year = int.parse('${arguments?['year']}');
    username = '${arguments?['username']}';
    albumName = '${arguments?['albumName']}';
    songName = '${arguments?['songName']}';
    performers = '${arguments?['performers']}';
    genre = '${arguments?['genre']}';
    albumId = int.parse('${arguments?['albumId']}');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('$albumName-$songName'),
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
                Navigator.pushReplacementNamed(context, '/personalPage',
                    arguments: {'userid': userid, 'username': username});
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 40),
            Text(
              'Song Details',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Performers:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/performerPage',
                        arguments: {'userid': userid, 'username': username,'performers':performers});
                  },
                  child: Text(
                    '$performers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Year: $year',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 8),
            Text(
              'Genre: $genre ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Go to the Album:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                IconButton(
                  icon: Icon(
                    Icons.album_rounded,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/albumPage',
                        arguments: {
                          'albumId': albumId,
                          'userid': userid,
                          'username': username,
                          'albumTitle':albumName
                        });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),

            Row(
              children: [
                Flexible(
                  child: Divider(
                    height: 5, // Set the height of the divider
                    thickness: 1, // Set the thickness of the divider
                    color: Colors.black, // Set the color of the divider
                  ),
                ),
              ],
            ),
            SongCard(
              songName: songName,
              albumId: albumId,
              genre: genre,
              songId: songId,
              songPerformers: performers,
              songYear: year.toString(),
              userid: userid,
              username: username,
            )
          ],
        ),
      ),
    );
  }
}
/*

bottomNavigationBar: Row(
        children: [
          Expanded(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: BeveledRectangleBorder()),
                onPressed: () {},
                child: Text('Delete Song (Not Implemented Yet)')),
          ),
        ],
      ),
 */

class SongCard extends StatelessWidget {
  final String songName, songPerformers, songYear, username, genre;
  final int songId, userid, albumId;

  SongCard(
      {required this.userid,
      required this.songName,
      required this.songPerformers,
      required this.songYear,
      required this.albumId,
      required this.songId,
      required this.username,
      required this.genre});

  void _onStarClicked(int starCount) {}
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/songPage', arguments: {
          'songId': songId,
          'userid': userid,
          'username': username
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Set to spaceBetween
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 20),
          SizedBox(
            height: 90,
            width: 90,
            child: Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'Song Image',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
          SizedBox(width: 4.0),
          Expanded(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 45),
                    Text(
                      songName,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      songPerformers,
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            child: SizedBox(
              width: 200,
            ),
          ),
          Column(
            children: [
              SizedBox(height: 35),
              IconButton(
                icon: Icon(
                    Icons.delete_forever_outlined),
                color: Colors.grey,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Delete'),
                        content: Text(
                            'Are you sure you want to delete this song? \n NOT IMPLEMENTED YET'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Delete'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

/*
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
                'Song Image',
                // You can replace this with actual album cover widget
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
          Row(
            children: [
              Text(
                'Go to album page:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
              IconButton(
                icon: Icon(
                  Icons.album_rounded,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/albumPage',
                      arguments: {
                        'albumId': songAlbum,
                        'userid': userid,
                        'username': username
                      });
                },
              ),
            ],
          )
        ],
      ),
    ],
  );
  }
 */

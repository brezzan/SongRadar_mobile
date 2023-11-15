import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'dart:convert';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';

class mainAppPage extends StatefulWidget {
  final int userid;
  final String username;
  const mainAppPage({required this.userid,required this.username, Key? key}) : super(key: key);

  @override
  State<mainAppPage> createState() => _mainAppPageState();
}

class _mainAppPageState extends State<mainAppPage> {
  late int userid;
  late String username ;

  List<Map<String, dynamic>> to_print_albums = [];
  List<Map<String, dynamic>> to_print_songs = [];
  late Future<List<Map<String, dynamic>>> albums;
  late Future<List<Map<String, dynamic>>> songs;
  late Future<Map<String, dynamic>> currentUser ;  // for printing username after getting id in arguments

  Future<void> fetchAlbums() async {
    albums = AuthService().getAlbums();  // future widget build to see album cards
    songs = AuthService().getSongs();

    to_print_albums = await AuthService().getAlbums();   // for the terminal
    to_print_songs = await AuthService().getSongs();
    print("all albums printed:   ");
    print(to_print_albums);
    print("----");
    print("all songs printed:   ");
    print(to_print_songs);
    print("----");
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
    userid = int.parse('${arguments?['userid']}');
    username = '${arguments?['username']}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Row(
          children: [
            Text('Welcome, $username'),
            Flexible(
              child: SizedBox(width: 200),
            ),
            IconButton(
              icon: Icon(
                Icons.music_note,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/addNewSong', arguments: {'userid': userid,'username':username});
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
        child: Column(children: <Widget>[
          SizedBox(height: 40),
          Text(
            'Recently Favorited -NOT IMPLEMENTED',
            textAlign: TextAlign.left,
          ),
          FutureBuilder(
            future: albums,
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While data is being fetched, you can show a loading indicator
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // If an error occurs during data fetching
                return Text('Error loading albums');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // If no albums are available
                return Text('No albums found');
              } else {
                // Data has been successfully fetched, build the list of AlbumCards
                List<Map<String, dynamic>> albums = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var album in albums)
                        AlbumCard(
                            albumName: album['title'].toString(),
                            albumPerformers: album['performers'].toString(),
                            albumYear: album['year'].toString(),
                            albumId: album['id'],
                            userid: userid,
                            username: username),
                    ],
                  ),
                );
              }
            },
          ),
          SizedBox(height: 80),
          Text(
            'Recommended -NOT IMPLEMENTED',
            textAlign: TextAlign.left,
          ),
          FutureBuilder(
            future: albums,
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While data is being fetched, you can show a loading indicator
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // If an error occurs during data fetching
                return Text('Error loading albums');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // If no albums are available
                return Text('No albums found');
              } else {
                // Data has been successfully fetched, build the list of AlbumCards
                List<Map<String, dynamic>> albums = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var album in albums)
                        AlbumCard(
                            albumName: album['title'].toString(),
                            albumPerformers: album['performers'].toString(),
                            albumYear: album['year'].toString(),
                            albumId: album['id'],
                            userid: userid,
                            username: username),
                    ],
                  ),
                );
              }
            },
          ),
          SizedBox(height: 80),
          Text(
            'Discover new Albums',
            textAlign: TextAlign.left,
          ),
          FutureBuilder(
            future: albums,
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While data is being fetched, you can show a loading indicator
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // If an error occurs during data fetching
                return Text('Error loading albums');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // If no albums are available
                return Text('No albums found');
              } else {
                // Data has been successfully fetched, build the list of AlbumCards
                List<Map<String, dynamic>> albums = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var album in albums)
                        AlbumCard(
                            albumName: album['title'].toString(),
                            albumPerformers: album['performers'].toString(),
                            albumYear: album['year'].toString(),
                            albumId: album['id'],
                            userid: userid,
                            username: username),
                    ],
                  ),
                );
              }
            },
          ),
        ]),
      ),
    );
  }
}

class AlbumCard extends StatelessWidget {
  final String albumName, albumPerformers, albumYear,username;
  final int albumId, userid;

  AlbumCard({
    required this.userid,
    required this.albumName,
    required this.albumPerformers,
    required this.albumYear,
    required this.albumId,
    required this.username
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/albumPage',
            arguments: {'albumId': albumId, 'userid': userid,'username':username});
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
                  'Album Cover', // You can replace this with actual album cover widget
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
                  '   ' + albumName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '   ' + albumPerformers,
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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'dart:convert';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';
import 'package:songradar/albumPage.dart';


class performerPage extends StatefulWidget {
  final int userid;
  final String username,performers;
  const performerPage(
      {
        required this.userid,
        required this.performers,
        required this.username,
        Key? key})
      : super(key: key);

  @override
  State<performerPage> createState() => _performerPageState();

}

class _performerPageState extends State<performerPage> {
  late String username, performers;
  late int userid;

  late Future<List<Map<String, dynamic>>> albums;

  Future<void> fetchAlbums() async {
    albums = AuthService().getAlbums();
  }
  Map<String, List<Map<String, dynamic>>> _groupAlbumsByYear(
        List<Map<String, dynamic>> albums, String performers) {
      Map<String, List<Map<String, dynamic>>> groupedAlbums = {};

      for (var album in albums) {
        if (album['performers'] == performers) {
          var year = album['year'].toString();

          if (!groupedAlbums.containsKey(year)) {
            groupedAlbums[year] = [];
          }

          groupedAlbums[year]!.add(album);
        }
      }

      return groupedAlbums;
  }

  @override
  void initState() {
    super.initState();
    fetchAlbums();
  }

  Widget build(BuildContext context) {
    final arguments =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userid = int.parse('${arguments?['userid']}');
    username = '${arguments?['username']}';
    performers = '${arguments?['performers']}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('$performers'),
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
      body:SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: Container(
                width: 140,
                height: 140,
                color: Colors.grey[200],
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Performer Photo',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('$performers',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      height: 5, // Set the height of the divider
                      thickness: 1, // Set the thickness of the divider
                      color: Colors.black, // Set the color of the divider
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder(
              future: albums,
              builder: (context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
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

                  List<Map<String, dynamic>> albums = snapshot.data!;
                  albums.sort((a, b) => b['year'].compareTo(a['year']));  // yıllara göre sırlaa

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        for (var year in _groupAlbumsByYear(albums, performers).keys)
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.0),
                                child: Row(

                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Flexible(
                                      child: Divider(
                                        height: 5,
                                        thickness: 1,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        year,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Flexible(
                                      child: Divider(
                                        height: 5,
                                        thickness: 1,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              for (var album in _groupAlbumsByYear(albums, performers)[year]!)
                                AlbumCard(
                                  albumId: album['id'],
                                  albumTitle: album['title'],
                                  username: username,
                                  userid: userid,
                                  year: album['year'],
                                ),
                            ],
                          ),
                      ],
                    ),
                  );

                }
              },
            ),
          ],
        ),
      )
    );
  }
}

class AlbumCard extends StatelessWidget {
  final int albumId, userid,year;
  final String username, albumTitle;

  AlbumCard({
    required this.albumId,
    required this.albumTitle,
    required this.username,
    required this.userid,
    required this.year,
    Key? key})
      : super(key: key);

  @override

  Widget build(BuildContext context) {
      return GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, '/albumPage', arguments: {
            'albumId': albumId,
            'albumTitle': albumTitle,
            'userid': userid,
            'username':username

          });
        },
        child: Container(
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
                      'Album Cover',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.0),
              Flexible(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 45),
                        Text(
                          '$albumTitle',
                          style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      );
    }
}



import 'package:flutter/material.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'package:songradar/variables.dart';

class performerPage extends StatefulWidget {
  final int userid;
  final String username, performers;
  const performerPage(
      {required this.userid,
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
  List<Map<String, dynamic>> albumsData = [];

  int rating = 0;
  void _onStarClicked(int starCount) {}

  Future<void> fetchAlbumsbyArtist() async {
    albumsData = await AuthService().getAlbumByArtist(global_artist);
    albumsData.sort((a, b) => b['year'].compareTo(a['year']));

    setState(() {
      albums = AuthService().getAlbumByArtist(global_artist);
    });

  }

  Map<String, List<Map<String, dynamic>>> _groupAlbumsByYear(
      List<Map<String, dynamic>> albums) {
    Map<String, List<Map<String, dynamic>>> groupedAlbums = {};

    for (var album in albums) {
      var year = album['year'].toString();
      if (!groupedAlbums.containsKey(year)) {
        groupedAlbums[year] = [];
      }
      groupedAlbums[year]!.add(album);
    }
    return groupedAlbums;
  }

  @override
  void initState() {
    super.initState();
    fetchAlbumsbyArtist();
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
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  height: 140, // Set the desired height for the box
                  width: 140, // Set the desired width for the box
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Icon(Icons.person,size:80,color: Colors.grey,),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('$performers',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Rating:',style: TextStyle(fontSize: 20)),
                  for (int i = 1; i <= 5; i++)
                    GestureDetector(
                      onTap: () {
                        // Handle star click, you can call your function here
                        _onStarClicked(i);
                      },
                      child: Icon(
                        i <= rating ? Icons.star : Icons.star_border,
                        color: Colors.yellow,
                        size: 30,
                      ),
                    ),
                ],
              ),
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
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                          for (var year in _groupAlbumsByYear(albumsData).keys)
                            Column(
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 25.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
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
                                for (var album in _groupAlbumsByYear(albumsData)[year]!)
                                  AlbumCard(
                                      username: username,
                                      userid: userid,
                                      album: Album(
                                          id: album['id'],
                                          name: album['name'],
                                          artists: album['artists'],
                                          artist_ids: album['artist_ids'],
                                          number_of_tracks:
                                              album['number_of_tracks'],
                                          explicit: album['explicit'],
                                          danceability: album['danceability'],
                                          energy: album['energy'],
                                          key: album['key'],
                                          loudness: album['loudness'],
                                          mode: album['mode'],
                                          speechiness: album['speechiness'],
                                          acousticness: album['acousticness'],
                                          instrumentalness:
                                              album['instrumentalness'],
                                          liveness: album['liveness'],
                                          valence: album['valence'],
                                          tempo: album['tempo'],
                                          duration_ms: album['duration_ms'],
                                          time_signature:
                                              album['time_signature'],
                                          year: album['year'],
                                          month: album['month'],
                                          day: album['day'],
                                          owner_id: album['owner_id'])),
                              ],
                            ),
                        ],

                  ),
              ),
            ],
          )
        ),
    );
  }
}

class AlbumCard extends StatelessWidget {
  final String username;
  final int userid;
  final Album album;

  AlbumCard(
      {required this.userid, required this.album, required this.username});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        global_albumId=  album.id;         /////////////////////////////////////////////////////////////////////
        Navigator.pushReplacementNamed(context, '/albumPage', arguments: {
          'albumId': album.id,
          'userid': userid,
          'username': username
        });
      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Set to spaceBetween
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 20),
            SizedBox(
              height: 90, // Set the desired height for the box
              width: 90, // Set the desired width for the box
              child: Container(
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: album.getVibeColor_energy(),
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Icon(Icons.album,size:40,color: Colors.grey,),
                ),
              ),
            ),
            SizedBox(width: 4.0),
            Expanded(
              child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          album.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

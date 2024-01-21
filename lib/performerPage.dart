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
            Flexible(child: Text('$performers')),
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
              SizedBox(
                height: 140,
                width: 140,
                child: Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: FutureBuilder<String>(
                      future: AuthService().getArtistCoverById(global_artist_id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            return Image.network(snapshot.data!);
                          } else {
                            // Handle the case when there's an error in fetching the image or no data
                            return Icon(Icons.album);
                          }
                        } else {
                          // While the future is still resolving, you can show a loading indicator
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('$performers',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),

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
                          for (var data
                              in _groupAlbumsByYear(albumsData)[year]!)
                            AlbumCard(
                                username: username,
                                userid: userid,
                                album: Album(
                                  id: data['id'] ?? '',
                                  name: data['name'] ?? '',
                                  artists: data['artists'] ?? '[]',
                                  artist_ids: data['artist_ids'] ?? '[]',
                                  number_of_tracks:
                                      data['number_of_tracks'] ?? 0,
                                  explicit: data['explicit'] ?? false,
                                  danceability: data['danceability'] ?? 0.0,
                                  energy: data['energy'] ?? 0.0,
                                  key: data['key'] ?? 0,
                                  loudness: data['loudness'] ?? 0.0,
                                  mode: data['mode'] ?? 0,
                                  speechiness: data['speechiness'] ?? 0.0,
                                  acousticness: data['acousticness'] ?? 0,
                                  instrumentalness:
                                      data['instrumentalness'] ?? 0,
                                  liveness: data['liveness'] ?? 0,
                                  valence: data['valence'] ?? 0,
                                  tempo: data['tempo'] ?? 0,
                                  duration_ms: data['duration_ms'] ?? 0,
                                  time_signature: data['time_signature'] ?? 0,
                                  year: data['year'] ?? 0,
                                  month: data['month'] ?? 0,
                                  day: data['day'] ?? 0,
                                  owner_id: data['owner_id'] ?? 0,
                                ))
                        ],
                      ),
                  ],
                ),
              ),
            ],
          )),
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
        global_albumId = album
            .id; /////////////////////////////////////////////////////////////////////
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
                  child: FutureBuilder<String>(
                    future: AuthService().getAlbumCoverById(album.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return Image.network(snapshot.data!);
                        } else {
                          // Handle the case when there's an error in fetching the image
                          return Text('Error loading image');
                        }
                      } else {
                        // While the future is still resolving, you can show a loading indicator
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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

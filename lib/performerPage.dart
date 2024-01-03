import 'package:flutter/material.dart';
import 'dart:core';
import 'package:songradar/api.dart';

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
  List<Map<String, dynamic>> albums_ = [];

  Future<void> fetchAlbumsbyArtist() async {
    albums = AuthService().getAlbumByArtistFromCsv(performers);
    albums_ = await AuthService().getAlbumByArtistFromCsv(performers);
    print(albums_);
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
  }

  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userid = int.parse('${arguments?['userid']}');
    username = '${arguments?['username']}';
    performers = '${arguments?['performers']}';
    print(performers);
    fetchAlbumsbyArtist();

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
              Text('$performers',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
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
                    return Text('No albums found');
                  } else {
                    List<Map<String, dynamic>> albums = snapshot.data!;

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          for (var year in _groupAlbumsByYear(albums).keys)
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
                                for (var album
                                    in _groupAlbumsByYear(albums)[year]!)
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
                    );
                  }
                },
              ),
            ],
          ),
        ));
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
        Navigator.pushReplacementNamed(context, '/albumPage', arguments: {
          'albumId': album.id,
          'albumTitle': album.name,
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
            Expanded(
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
                        maxLines: 4, // Set the maximum number of lines
                        overflow: TextOverflow.ellipsis, // Add ellipsis (...) if the text overflows
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

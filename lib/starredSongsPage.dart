import 'package:flutter/material.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'package:songradar/variables.dart';

class starredSongsPage extends StatefulWidget {
  final int userid;
  final String username;
  const starredSongsPage(
      {required this.userid, required this.username, Key? key})
      : super(key: key);

  @override
  State<starredSongsPage> createState() => _starredSongsPageState();
}

class _starredSongsPageState extends State<starredSongsPage> {
  late String username;
  late int userid;
  List<dynamic> songs = [];
  ScrollController _scrollControllerSong = ScrollController();

  int currentPageSong = 1;
  int pageSize = 30;

  Future<List<dynamic>> fetchStarred() async {
    return await AuthService().getStarred();
  }

  Future<void> loadStarred() async {
    var starredSongs = await fetchStarred();
    setState(() {
      songs.addAll(starredSongs);
    });
  }

  void _scrollListenerSong() {
    if (_scrollControllerSong.position.pixels == _scrollControllerSong.position.maxScrollExtent) {
      currentPageSong++;
      loadStarred();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollControllerSong.addListener(_scrollListenerSong);
    loadStarred();
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 40,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/personalPage',
                    arguments: {'userid': userid, 'username': username});
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text('Favorite Songs'),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.logout,
                size: 40,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Log Out ?'),
                      content: Text(
                        'Are you sure you want to log out?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login',
                                arguments: {});
                          },
                          child: Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('No'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollControllerSong,
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  for (var song in songs)
                    SongCard(
                        userid: userid,
                        username: username,
                        song: Song(
                            id: song['id'],
                            name: song['name'],
                            album: song['album'],
                            album_id: song['album_id'],
                            artists: song['artists'],
                            artist_ids: song['artist_ids'],
                            track_number: 0,
                            disc_number:0,
                            explicit: song['explicit'],
                            danceability: song['danceability'],
                            energy: song['energy'],
                            key: song['key'],
                            loudness: song['loudness'],
                            mode: song['mode'],
                            speechiness: song['speechiness'],
                            acousticness: song['acousticness'],
                            instrumentalness: song['instrumentalness'],
                            liveness: song['liveness'],
                            valence: song['valence'],
                            tempo: song['tempo'],
                            duration_ms: song['duration_ms'],
                            time_signature: song['time_signature'],
                            year: song['year'],
                            month: song['month'],
                            day: song['day'],
                            owner_id: song['owner_id']))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class SongCard extends StatelessWidget {
  final String username;
  final int userid;
  final Song song;

  SongCard(
      {required this.userid,
        required this.username,
        required this.song});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        global_songId=  song.id;         /////////////////////////////////////////////////////////////////////////
        Navigator.pushReplacementNamed(context, '/songPage', arguments: {
          'userid': userid,
          'username': username,
          'songId': song.id
        });
      },
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
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
                color: song.getVibeColor_energy(),
              ),
              child: Center(
                child: FutureBuilder<String>(
                  future: AuthService().getSongCoverById(song.id),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 45),
                Text(
                  song.name,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  song.artists,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 4),
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
                  Icons.delete_forever_outlined,
                  size: 25,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Remove From Favorites'),
                        content: Text(
                            'Are you sure you want to remove this from favorites?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Delete'),
                            onPressed: () async{
                              await AuthService().UnstarASong(song.id);
                              Navigator.pushReplacementNamed(context, '/starredSongsPage',
                                  arguments: {'userid': userid, 'username': username});
                              //
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                color: Colors.grey,
              ),
            ],
          )
        ],
      ),
    );
  }
}
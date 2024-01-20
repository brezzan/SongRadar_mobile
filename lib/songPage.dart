import 'package:flutter/material.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'package:songradar/variables.dart';

class songPage extends StatefulWidget {
  final int  userid ;
  final String username,songId;


  const songPage({required this.userid,required this.songId ,required this.username,
      Key? key})
      : super(key: key);

  @override
  State<songPage> createState() => _songPageState();
}

class _songPageState extends State<songPage> {
  int rating = 0;
  void _onStarClicked(int starCount) {}

  late String username, songId;
  late int userid;

  late Song song = Song(id: '', name: '', album: '', album_id: '', artists: '', artist_ids: '', disc_number: 0, track_number: 0, explicit: false,
                        danceability: 0.0, energy: 0.0, key: 0, loudness: 0.0, mode: 0, speechiness: 0.0, acousticness: 0,
                        instrumentalness: 0, liveness: 0, valence: 0, tempo: 0,
                        duration_ms: 0, time_signature: 0, year: 0, month: 0, day: 0, owner_id: 0,);

  late Future<Map<String, dynamic>> songData ;
  Map<String, dynamic> data = {};


  Future<void> fecthsong() async {
    data = await AuthService().getSongById(global_songId);

    setState(() {
      print(global_songId);
      songData = AuthService().getSongById(global_songId);

      song = Song(
        id: data['id'],
        name: data['name'],
        album: data['album'],
        album_id: data['album_id'],
        artists: data['artists'],
        artist_ids: data['artist_ids'],
        track_number: 0,
        disc_number: 0,
        explicit: data['explicit'],
        danceability: data['danceability'],
        energy: data['energy'],
        key: data['key'],
        loudness: data['loudness'],
        mode: data['mode'],
        speechiness: data['speechiness'],
        acousticness: data['acousticness'],
        instrumentalness: data['instrumentalness'],
        liveness: data['liveness'],
        valence: data['valence'],
        tempo: data['tempo'],
        duration_ms: data['duration_ms'],
        time_signature: data['time_signature'],
        year: data['year'],
        month: data['month'],
        day: data['day'],
        owner_id: data['owner_id'],
      );
    });
  }

  @override
  void initState() {
    super.initState();
    fecthsong();

  }

  bool isStarred(String songId){

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
    ModalRoute
        .of(context)
        ?.settings
        .arguments as Map<String, dynamic>?;
    userid = int.parse('${arguments?['userid']}');
    username = '${arguments?['username']}';
    songId = '${arguments?['songId']}';


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(song.name),
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
                    arguments: {
                      'userid': userid,
                      'username': username
                    });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.person_pin_rounded,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/personalPage',
                    arguments: {
                      'userid': userid,
                      'username': username
                    });
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text(
                  'Album:',
                  style: TextStyle(fontSize: 20),
                ),
                InkWell(
                  onTap: () {
                    global_albumId = song.album_id; /////////////////////////////////////////////////////////////////////
                    Navigator.pushReplacementNamed(
                        context, '/albumPage', arguments: {
                      'albumId': song.id,
                      'userid': userid,
                      'username': username
                    });
                  },
                  child: Text(
                    song.album.trim(),
                    // trim to remove leading/trailing spaces
                    style: TextStyle(fontSize: 20,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Song: ${song.name}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              'Performers:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var artist in song.artists.split(","))
                  InkWell(
                    onTap: () {
                      global_artist =
                          artist; ////////////////////////////////////////////////////////////
                      Navigator.pushReplacementNamed(
                          context, '/performerPage',
                          arguments: {
                            'userid': userid,
                            'username': username,
                            'performers': artist
                          });
                    },
                    child: Text(
                      artist.trim(),
                      // trim to remove leading/trailing spaces
                      style: TextStyle(fontSize: 20,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.underline),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Publish Date: ${song.day}-${song.month}-${song.year}',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 16),
            Text(
              'Duration: ${song.duration_ms ~/ 60000}:${(song
                  .duration_ms %
                  60000 ~/ 1000).toString().padLeft(2, '0')}',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Rating:', style: TextStyle(fontSize: 20)),
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
            SizedBox(height:10),
            song.getCharacteristicsChart(),
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
            SongCard(userid: userid, song: song, username: username),
            SizedBox(height:40),
          ],
        ),
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
      required this.song,
      required this.username,
     });

  void _onStarClicked(int starCount) {}
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    return  Row(
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
            flex: 3,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 45),
                    Text(
                      song.name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      song.artists,
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              width: 10,
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
      );
  }
}

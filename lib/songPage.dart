import 'package:flutter/material.dart';
import 'dart:core';
import 'package:songradar/api.dart';

class songPage extends StatefulWidget {
  final int  userid ;
  final String username,id;
  final Song song;

  const songPage({required this.userid,required this.id ,required this.username, required this.song,
      Key? key})
      : super(key: key);

  @override
  State<songPage> createState() => _songPageState();
}

class _songPageState extends State<songPage> {
  late String username, id;
  late int userid; // Corrected variable name to userId
  late Song song;
  late Future<Map<String, dynamic>> song_data;
  int rating = 0;
  void _onStarClicked(int starCount) {}

  Future<void> fecthsong()  async{
    song_data = AuthService().getSongByIdFromCsv(id);
    print(song_data);
}

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userid = int.parse('${arguments?['userid']}');
    username = '${arguments?['username']}';
    id = '${arguments?['id']}';
    song = arguments?['song'];


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
                      Navigator.pushReplacementNamed(context, '/albumPage',
                          arguments: {
                            'albumId': song.album_id,
                            'userid': userid,
                            'username': username,
                          });
                  },
                  child: Text(
                    song.album.trim(), // trim to remove leading/trailing spaces
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Song: ${song.name}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize:20),
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
                      Navigator.pushReplacementNamed(context, '/performerPage',
                          arguments: {'userid': userid, 'username': username, 'performers': song.artists});
                    },
                    child: Text(
                      artist.trim(), // trim to remove leading/trailing spaces
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, decoration: TextDecoration.underline),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Publish Date: ${song.year} - ${song.month} - ${song.day}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 16),
            Text(
              'Duration: ${song.duration_ms ~/ 60000}:${(song.duration_ms % 60000 ~/ 1000).toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 16),
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
              userid: userid,
              username: username,
              song :song
            )
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
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/songPage', arguments: {
          'songId': song.id,
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
      ),
    );
  }
}

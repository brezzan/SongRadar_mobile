import 'package:flutter/material.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'package:songradar/variables.dart';

class albumPage extends StatefulWidget {
  final int userid; // Corrected variable name to userId
  final String username, albumTitle,albumId;
  const albumPage(
      {required this.albumId,
      required this.albumTitle,
      required this.userid,
      required this.username,
      Key? key})
      : super(key: key);

  @override
  State<albumPage> createState() => _albumPageState();
}

class _albumPageState extends State<albumPage> {
  late int userid, year; // Corrected variable name to userId
  late String username, albumTitle, performers, genre,albumId;

  List<Map<String, dynamic>> to_print_albums = [];
  List<Map<String, dynamic>> to_print_songs = [];
  //late Future<List<Map<String, dynamic>>> albums;
  //late Future<List<Map<String, dynamic>>> songs;
  late Future<Map<String, dynamic>> currentUser ;  // for printing username after getting id in arguments

  /*
  List<Map<String, dynamic>> to_print_albums = [];
  List<Map<String, dynamic>> to_print_songs = [];
  //late Future<List<Map<String, dynamic>>> albums;
  late Future<List<Map<String, dynamic>>> songs;

   */

  Future<void> fetchData() async {
    //songs = AuthService().getSongsFromCsv();
    //to_print_songs = await AuthService().getSongsFromCsv();

    print("----");
    print("all songs printed:   ");
    print(global_songs);
    print("----");
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    print("Albums: ");
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userid = int.parse('${arguments?['userid']}');
    albumId = '${arguments?['albumId']}';
    username = '${arguments?['username']}';
    albumTitle = '${arguments?['albumTitle']}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Row(
          children: [
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
            Text('$albumTitle'),
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
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 20),
                Container(
                  width: 140,
                  height: 140,
                  color: Colors.grey[200],
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Album cover',
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Center(
                    child: FutureBuilder(
                      future: global_songs ,
                      builder: (context,
                          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // While data is being fetched, you can show a loading indicator
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          // If an error occurs during data fetching
                          return Text('Error loading songs');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          // If no albums are available
                          return Text('No songs found');
                        } else {
                          // Data has been successfully fetched, build the list of AlbumCards
                          List<Map<String, dynamic>> global_songs = snapshot.data!;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              children: [
                                for (var album in global_songs)
                                  if (album['id'] == albumId)
                                    albumInfo(
                                      albumName: albumTitle.toString(),
                                      performers: album['artists'].toString(),
                                      //genre: album['genre'].toString(),
                                      year: album['year'].toString(),
                                      username: username,
                                      userid: userid,
                                    )
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.delete_forever_outlined,
                        size: 35,
                      ),
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
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      color: Colors.grey,
                    ),
                    SizedBox(height: 100),
                  ],
                )
              ],
            ),
            Row(
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
            FutureBuilder(
              future: global_songs,
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
                  // Data has been successfully fetched, build the list of AlbumCards
                  List<Map<String, dynamic>> global_songs = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        for (var song in global_songs)
                          if (song['album_id'] == albumId)
                            SongCard(
                                songName: song['name'].toString(),
                                songPerformers: song['artists'].toString(),
                                songYear: song['year'].toString(),
                                songId: song['id'].toString(),
                                albumId: song['album_id'].toString(),
                                albumName: albumTitle,
                                userid: userid,
                                username: username),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SongCard extends StatelessWidget {
  final String songName, songPerformers, songYear, username, albumName,songId, albumId;
  final int userid;
  void deletesong() {}

  SongCard(
      {required this.userid,
      required this.songName,
      required this.songPerformers,
      required this.songYear,
      required this.songId,
      required this.albumId,
      required this.albumName,
      required this.username});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/songPage', arguments: {
          'songId': songId,
          'songName':songName,
          'albumName': albumName,
          'userid': userid,
          'albumId': albumId,
          'year': int.parse(songYear),
          'performers': songPerformers,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 45),
                Text(
                  songName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  songPerformers,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
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
                color: Colors.grey,
                onPressed: deletesong,
                icon: Icon(
                    Icons.settings), // Wrap Icons.settings in an Icon widget
              ),
            ],
          )
        ],
      ),
    );
  }
}

class albumInfo extends StatelessWidget {
  final String albumName, performers, year, username;
  final int userid;
  //final int rating;
  const albumInfo({
    required this.albumName,
    required this.performers,
    required this.year,
    required this.username,
    required this.userid
  });

  @override
  Widget build(BuildContext context) {
    int rating = 0;
    void _onStarClicked(int starCount) {}

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text('Album Name: $albumName'),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Performers: ',
              textAlign: TextAlign.center,
            ),
            InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/performerPage',
                    arguments: {'userid': userid, 'username': username,'performers':performers});
              },
              child: Text(
                '$performers',
                style: TextStyle(fontWeight: FontWeight.normal, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Text('Genre: '),
        SizedBox(height: 15),
        Text('Year: $year'),
        SizedBox(height: 10),
        Row(
          children: [
            Text('Rating:'),
            for (int i = 1; i <= 5; i++)
              GestureDetector(
                onTap: () {
                  // Handle star click, you can call your function here
                  _onStarClicked(i);
                },
                child: Icon(
                  i <= rating ? Icons.star : Icons.star_border,
                  color: Colors.yellow,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/*
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
 */

/*
bottomNavigationBar: Row(
        children: [
          Expanded(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: BeveledRectangleBorder()),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Delete'),
                        content:
                            Text('Are you sure you want to delete this album?'),
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
                                final Map<String, dynamic> deletedAlbum =
                                    await AuthService().deleteAlbum(albumId);
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
                                              Navigator.pushReplacementNamed(
                                                  context, '/mainAppPage',
                                                  arguments: {
                                                    'userid': userid,
                                                    'username': username
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
                                        content:
                                            Text('Album could not be deleted'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
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
                child: Text('Delete Album')),
          ),
        ],
      ),
 */



/*
onPressed: () async {

                                      final Map<String, dynamic> deletedAlbum =
                                          await AuthService()
                                              .deleteAlbum(albumId);
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
                                                    Navigator
                                                        .pushReplacementNamed(
                                                            context,
                                                            '/mainAppPage',
                                                            arguments: {
                                                          'userid': userid,
                                                          'username': username
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
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    }) ,  */
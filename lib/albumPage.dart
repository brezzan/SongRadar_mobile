import 'package:flutter/material.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'package:songradar/variables.dart';

List<dynamic> starredSongs = [];

class albumPage extends StatefulWidget {
  final int userid; // Corrected variable name to userId
  final String username,albumId;

  const albumPage({required this.albumId, required this.userid, required this.username,
      Key? key})
      : super(key: key);

  @override
  State<albumPage> createState() => _albumPageState();

}

class _albumPageState extends State<albumPage> {
  late int userid;
  late String username, albumId;

  late Future<Map<String, dynamic>> albumData; // Adjusted the type
  late Album album = Album(
    id: '', name: '', artists: "[]", artist_ids: "[]", number_of_tracks: 0, explicit: false,
    danceability: 0.0, energy: 0.0, key: 0, loudness: 0.0, mode: 0, speechiness: 0.0, acousticness: 0, instrumentalness: 0,
    liveness: 0, valence: 0, tempo: 0, duration_ms: 0, time_signature: 0, year: 0, month: 0, day: 0, owner_id: 0,
  );

  Map<String, dynamic> data ={};
  late List<Song> tracks = [];

  Future<void> fetchData() async {

    data = await AuthService().getAlbumById(global_albumId);


    setState(() {

    albumData = AuthService().getAlbumById(global_albumId);

    album = Album(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      artists: data['artists'] ?? "[]",
      artist_ids: data['artist_ids'] ?? "[]",
      number_of_tracks: data['number_of_tracks'] ?? 0,
      explicit: data['explicit'] ?? false,
      danceability: data['danceability'] ?? 0.0,
      energy: data['energy'] ?? 0.0,
      key: data['key'] ?? 0,
      loudness: data['loudness'] ?? 0.0,
      mode: data['mode'] ?? 0,
      speechiness: data['speechiness'] ?? 0.0,
      acousticness: data['acousticness'] ?? 0,
      instrumentalness: data['instrumentalness'] ?? 0,
      liveness: data['liveness'] ?? 0,
      valence: data['valence'] ?? 0,
      tempo: data['tempo'] ?? 0,
      duration_ms: data['duration_ms'] ?? 0,
      time_signature: data['time_signature'] ?? 0,
      year: data['year'] ?? 0,
      month: data['month'] ?? 0,
      day: data['day'] ?? 0,
      owner_id: data['owner_id'] ?? 0,
    );

    for (var data in data['tracks']){
      tracks.add(Song(
        id: data['id']?? '',
        name: data['name']?? '',
        album: data['album']?? '',
        album_id: data['album_id']?? "[]",
        artists: data['artists']?? "[]",
        artist_ids: data['artist_ids']?? '',
        track_number: 0,
        disc_number: 0,
        explicit: data['explicit']?? false,
        danceability: data['danceability']?? 0,
        energy: data['energy']?? 0,
        key: data['key']?? 0,
        loudness: data['loudness']?? 0,
        mode: data['mode']?? 0,
        speechiness: data['speechiness']?? 0,
        acousticness: data['acousticness']?? 0,
        instrumentalness: data['instrumentalness']?? 0,
        liveness: data['liveness']?? 0,
        valence: data['valence']?? 0,
        tempo: data['tempo']?? 0,
        duration_ms: data['duration_ms']?? 0,
        time_signature: data['time_signature']?? 0,
        year: data['year']?? 0,
        month: data['month']?? 0,
        day: data['day']?? 0,
        owner_id: data['owner_id']?? 0,

      ));
    }
    });

  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userid = int.parse('${arguments?['userid']}');
    albumId = '${arguments?['albumId']}';
    username = '${arguments?['username']}';

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.deepOrange,
              title: Row(
                children: [
                  Flexible(child: Text(album.name)), // album name
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
                      SizedBox(width: 15),
                      SizedBox(
                        height: 140,
                        width: 140,
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
                      SizedBox(width: 20),
                      Expanded(
                        child: Center(
                          child: albumInfo(
                            userid: userid,
                            username: username,
                            album: album,
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
                                        onPressed: () async {
                                          await AuthService().deleteAlbum(album.id);

                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Deleted Album'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pushReplacementNamed(context, '/mainAppPage',
                                                          arguments: {'userid': userid, 'username': username});
                                                    },
                                                    child: Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
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
                  SizedBox(height: 10,),
                  album.getCharacteristicsChart(),
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
                  for (var song in tracks)
                    SongCard(userid: userid, username: username, song: song)

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
                        return Icon(Icons.music_note );
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
                  song.artists[0],
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal ),
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
                        title: Text('Confirm Delete'),
                        content: Text(
                            'Are you sure you want to delete this song?'),
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
                              await AuthService().deleteSong(song.id);

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Deleted Song'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacementNamed(context, '/albumPage',
                                              arguments: {'albumId':global_albumId,'userid': userid, 'username': username});
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
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

class albumInfo extends StatelessWidget {
  final String username;
  final int userid;
  final Album album;

  const albumInfo({
    required this.username,
    required this.userid,
    required this.album
  });



  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Center(child: Text('${album.name}',)),
        SizedBox(height: 15),
        Text(
          'Performers:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < album.artists.length; i++)

              InkWell(
                onTap: () {
                  global_artist = album.artists[i]; //////////////////////////////////////////////////////////////////////
                  global_artist_id = album.artist_ids[i];
                  Navigator.pushReplacementNamed(context, '/performerPage',
                      arguments: {'userid': userid, 'username': username, 'performers': global_artist });
                },
                child: Text(
                  album.artists[i].trim(), // trim to remove leading/trailing spaces
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, decoration: TextDecoration.underline),
                ),
              ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          'Publish Date: ${album.day}-${album.month}-${album.year}',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
        ),
        SizedBox(height: 10),

      ],
    );
  }
}








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


/*
return FutureBuilder(
      future: albumData,
      builder: (context,
          AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While data is being fetched, you can show a loading indicator
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If an error occurs during data fetching
          return Text('Error loading albums');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // If no albums are available
          return Text('No album found');
        } else {
          // Data has been successfully fetched, build the list of AlbumCards
          Map<String, dynamic> albumData = snapshot.data!;
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
                  Text('  '), // album name
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
                          child: albumInfo(
                              userid: userid,
                              username: username,
                              album: album,
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
                  for (var song in tracks)
                    SongCard(userid: userid, username: username, song: song)

                ],
              ),
            ),
          );
        }
      },
    );*/
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


  late String username, songId;
  late int userid;

  late Song song = Song(id: '', name: '', album: '', album_id: '', artists: '', artist_ids: '', disc_number: 0, track_number: 0, explicit: false,
    danceability: 0.0, energy: 0.0, key: 0, loudness: 0.0, mode: 0, speechiness: 0.0, acousticness: 0,
    instrumentalness: 0, liveness: 0, valence: 0, tempo: 0,
    duration_ms: 0, time_signature: 0, year: 0, month: 0, day: 0, owner_id: 0,);

  late Future<Map<String, dynamic>> songData ;
  Map<String, dynamic> data = {};
  List<dynamic> recommended = [];

  List<dynamic>playlists = [];


  Future<void> fecthsong() async {
    data = await AuthService().getSongById(global_songId);
    playlists = await AuthService().getUserPlaylists();

    recommended = await AuthService().recommend(global_songId,recommend: 10);


    setState(() {

      song = Song(
        id: data['id']?? '',
        name: data['name']?? '',
        album: data['album']?? '',
        album_id: data['album_id']?? '',
        artists: data['artists']?? '[]',
        artist_ids: data['artist_ids']?? '[]',
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

      );

    });
  }

  @override
  void initState() {
    super.initState();
    fecthsong();

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
        backgroundColor: Colors.grey,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(child: Text(song.name,)),
            const Flexible(
              child: SizedBox(width: 200),
            ),
            IconButton(
              icon: const Icon(
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
              icon: const Icon(
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
            const SizedBox(height: 40),
            Text(
              'Song: ${song.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const Text(
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
                    style: const TextStyle(fontSize: 20,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.underline),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Performers:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                for (var i = 0; i < song.artists.length; i++)
                  InkWell(
                    onTap: () {
                      global_artist = song.artists[i]; ////////////////////////////////////////////////////////////
                      global_artist_id = song.artist_ids[i];
                      Navigator.pushReplacementNamed(
                          context, '/performerPage',
                          arguments: {
                            'userid': userid,
                            'username': username,
                            'performers': global_artist
                          });
                    },
                    child: Text(
                      song.artists[i].trim(),
                      // trim to remove leading/trailing spaces
                      style: const TextStyle(fontSize: 20,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.underline),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Publish Date: ${song.day}-${song.month}-${song.year}',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 16),
            Text(
              'Duration: ${song.duration_ms ~/ 60000}:${(song
                  .duration_ms %
                  60000 ~/ 1000).toString().padLeft(2, '0')}',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Rating:', style: TextStyle(fontSize: 20)),
                FutureBuilder<bool>(
                  future: AuthService().isStarred(song.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      bool isStarred = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          size: 30,
                          color: isStarred ? Colors.yellow : Colors.grey,
                        ),
                        onPressed: () async {
                          if (await AuthService().isStarred(song.id)) {
                            await AuthService().UnstarASong(song.id);
                          } else {
                            await AuthService().starASong(song.id);
                          }
                          setState(() { });
                        },
                        color: Colors.grey,
                      );
                    } else {
                      // You can return a loading indicator or a default color here
                      return const CircularProgressIndicator();
                    }
                  },
                ),

                FutureBuilder<List<dynamic>>(
                  future: AuthService().getUserPlaylists(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      List<dynamic> playlists = snapshot.data ?? [];
                      return IconButton(
                        icon: Icon(
                          Icons.view_headline_sharp,
                          size: 30,
                        ),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Select a Playlist'),
                                content: Container(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: playlists.length,
                                    itemBuilder: (context, index) {
                                      var element = playlists[index];
                                      return GestureDetector(
                                        onTap: () async {
                                          Map<String, dynamic> result =await AuthService().putToPlaylist(songId, element['id']);
                                          if(result.containsKey('error'))
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Could not add to Playlist'),
                                              content: Text('${result['error']}'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('OK'),
                                                ),
                                              ],
                                            );
                                          },);
                                          else{
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("Added to playlist ${element['name']}"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text('OK'),
                                                    ),
                                                  ],
                                                );
                                              },);
                                          }
                                          // Close the dialog
                                        },
                                        child: Text(element['name']),
                                      );
                                    },
                                  ),
                                ),

                              );
                            },
                          );

                          setState(() {});
                        },
                        color: Colors.grey,
                      );
                    } else {
                      // You can return a loading indicator or a default color here
                      return const CircularProgressIndicator();
                    }
                  },
                )

              ],
            ),
            Row(
              children: [
                const Flexible(
                  child: Divider(
                    height: 5, // Set the height of the divider
                    thickness: 1, // Set the thickness of the divider
                    color: Colors.black, // Set the color of the divider
                  ),
                ),
              ],
            ),
            const SizedBox(height:10),
            SongCard(userid: userid, song: song, username: username),
            const SizedBox(height:10),
            Row(
              children: [
                const Flexible(
                  child: Divider(
                    height: 5, // Set the height of the divider
                    thickness: 1, // Set the thickness of the divider
                    color: Colors.black, // Set the color of the divider
                  ),
                ),
              ],
            ),
            const SizedBox(height:10),
            song.getCharacteristicsChart(),
            const SizedBox(height:20),
            const Text('You may like these Songs:',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
            const SizedBox(height:10),
            SingleChildScrollView(

              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var recSong in recommended)
                    RecSongCard(userid: userid,
                      username: username ,
                        song: Song(
                        id: recSong['id']?? '',
                        name: recSong['name']?? '',
                        album: recSong['album']?? '',
                        album_id: recSong['album_id']?? '',
                        artists: recSong['artists']?? '[]',
                        artist_ids: recSong['artist_ids']?? '[]',
                        track_number: 0,
                        disc_number: 0,
                        explicit: recSong['explicit']?? false,
                        danceability: recSong['danceability']?? 0,
                        energy: recSong['energy']?? 0,
                        key: recSong['key']?? 0,
                        loudness: recSong['loudness']?? 0,
                        mode: recSong['mode']?? 0,
                        speechiness: recSong['speechiness']?? 0,
                        acousticness: recSong['acousticness']?? 0,
                        instrumentalness: recSong['instrumentalness']?? 0,
                        liveness: recSong['liveness']?? 0,
                        valence: recSong['valence']?? 0,
                        tempo: recSong['tempo']?? 0,
                        duration_ms: recSong['duration_ms']?? 0,
                        time_signature: recSong['time_signature']?? 0,
                        year: recSong['year']?? 0,
                        month: recSong['month']?? 0,
                        day: recSong['day']?? 0,
                        owner_id: recSong['owner_id']?? 0,))
                ],
              ),
            ),
            const SizedBox(height:60),
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



  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.start, // Set to spaceBetween
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 20),
        SizedBox(
          height: 90, // Set the desired height for the box
          width: 90, // Set the desired width for the box
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8.0),
              color: song.getVibeColor_energy(),
            ),
            child: Center(
              child: FutureBuilder<String>(
                future: AuthService().getSongCoverById(global_songId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return Image.network(snapshot.data!);
                    } else {
                      // Handle the case when there's an error in fetching the image
                      return const Icon(Icons.music_note );
                    }
                  } else {
                    // While the future is still resolving, you can show a loading indicator
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 4.0),
        Expanded(
          flex: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 45),
                  Text(
                    song.name,
                    style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artists[0],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Expanded(
          child: SizedBox(
            width: 10,
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 35),
            IconButton(
              icon: const Icon(
                  Icons.delete_forever_outlined),
              color: Colors.grey,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: const Text(
                          'Are you sure you want to delete this song?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Delete'),
                          onPressed: () async{
                            print('gonna delete song with ${song.id}');
                            Map<String, dynamic> response = await AuthService().deleteSong(song.id);

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('...Deleting Song...'),
                                  content: Text('${response['success']}'),

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
                            //
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

class RecSongCard extends StatelessWidget {
  final String username;
  final int userid;
  final Song song;

  RecSongCard({required this.userid, required this.username, required this.song});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        global_songId = song.id; /////////////////////////////////////////////////////////////////////////
        global_albumId = song.album_id;
        Navigator.pushReplacementNamed(context, '/songPage', arguments: {
          'userid': userid,
          'username': username,
          'songId': song.id
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
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
                        return const Text('Error loading image');
                      }
                    } else {
                      // While the future is still resolving, you can show a loading indicator
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 4.0), // Adjust the spacing between the box and the text
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  ' ' +(song.name.length > 15 ? song.name.substring(0, 15) :song.name),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  ' ' +(song.album.length > 15 ? song.album.substring(0, 15) :song.album),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
            for (var recSong in recommended)
              SongCard(userid: userid,
                  username: username ,song: Song(
                    id: recSong['id']?? '',
                    name: recSong['name']?? '',
                    album: recSong['album']?? '',
                    album_id: recSong['album_id']?? '',
                    artists: recSong['artists']?? '',
                    artist_ids: recSong['artist_ids']?? '',
                    track_number: 0,
                    disc_number: 0,
                    explicit: recSong['explicit']?? false,
                    danceability: recSong['danceability']?? 0,
                    energy: recSong['energy']?? 0,
                    key: recSong['key']?? 0,
                    loudness: recSong['loudness']?? 0,
                    mode: recSong['mode']?? 0,
                    speechiness: recSong['speechiness']?? 0,
                    acousticness: recSong['acousticness']?? 0,
                    instrumentalness: recSong['instrumentalness']?? 0,
                    liveness: recSong['liveness']?? 0,
                    valence: recSong['valence']?? 0,
                    tempo: recSong['tempo']?? 0,
                    duration_ms: recSong['duration_ms']?? 0,
                    time_signature: recSong['time_signature']?? 0,
                    year: recSong['year']?? 0,
                    month: recSong['month']?? 0,
                    day: recSong['day']?? 0,
                    owner_id: recSong['owner_id']?? 0,

                  ) ),*/

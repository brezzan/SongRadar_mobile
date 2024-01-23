import 'package:flutter/material.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'package:songradar/variables.dart';

class userAddedMusic extends StatefulWidget {
  final int userid;
  final String username;
  const userAddedMusic({required this.userid, required this.username, Key? key})
      : super(key: key);

  @override
  State<userAddedMusic> createState() => _userAddedMusicState();
}

class _userAddedMusicState extends State<userAddedMusic> {
  late int userid;
  late String username;

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userid = int.parse('${arguments?['userid']}');
    username = '${arguments?['username']}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 40,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/mainAppPage',
                    arguments: {'userid': userid, 'username': username});
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text('$username\'s Page'),
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 80),
            songList(userid: userid, username: username),
            SizedBox(height: 80),
            albumList(userid: userid, username: username),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class songList extends StatefulWidget {
  final int userid;
  final String username;
  const songList({required this.userid, required this.username, Key? key})
      : super(key: key);

  @override
  State<songList> createState() => _songListState();
}

class _songListState extends State<songList> {
  late int userid;
  late String username;

  ScrollController _scrollControllerSong =
      ScrollController(); // lazy loading for album

  List<dynamic> songs_to_print = [];

  int pageSize = 5; // Adjust the page size according to your needs

  int currentPageSong = 1;

  Future<void> fetchSongs() async {
    songs_to_print = await AuthService()
        .readUserSongs(skip: (currentPageSong - 1) * pageSize, limit: pageSize);
    setState(() {});
  }

  void _scrollListenerSong() {
    if (_scrollControllerSong.position.pixels ==
        _scrollControllerSong.position.maxScrollExtent) {
      // Reached the bottom of the list, load more albums
      currentPageSong++;
      fetchSongs();
    } else if (_scrollControllerSong.position.pixels ==
        _scrollControllerSong.position.minScrollExtent) {
      // Reached the top of the list, load previous albums
      if (currentPageSong > 1) {
        currentPageSong--;
        fetchSongs();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollControllerSong.addListener(_scrollListenerSong);
    fetchSongs().then((_) {
      //searchbar related
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your songs',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var global_song in songs_to_print)
                SongCard(
                    userid: widget.userid,
                    username: widget.username,
                    song: Song(
                        id: global_song['id'] ?? '',
                        name: global_song['name'] ?? '',
                        album: global_song['album'] ?? '',
                        album_id: global_song['album_id'] ?? '',
                        artists: global_song['artists'] ?? '[]',
                        artist_ids: global_song['artist_ids'] ?? '[]',
                        track_number: 0,
                        disc_number: 0,
                        explicit: global_song['explicit'] ?? false,
                        danceability: global_song['danceability'] ?? 0,
                        energy: global_song['energy'] ?? 0,
                        key: global_song['key'] ?? 0,
                        loudness: global_song['loudness'] ?? 0,
                        mode: global_song['mode'] ?? 0,
                        speechiness: global_song['speechiness'] ?? 0,
                        acousticness: global_song['acousticness'] ?? 0,
                        instrumentalness: global_song['instrumentalness'] ?? 0,
                        liveness: global_song['liveness'] ?? 0,
                        valence: global_song['valence'] ?? 0,
                        tempo: global_song['tempo'] ?? 0,
                        duration_ms: global_song['duration_ms'] ?? 0,
                        time_signature: global_song['time_signature'] ?? 0,
                        year: global_song['year'] ?? 0,
                        month: global_song['month'] ?? 0,
                        day: global_song['day'] ?? 0,
                        owner_id: global_song['owner_id'] ?? 0)),
              if(songs_to_print.isEmpty)
                Text('No songs added by ${widget.username}'),
            ],
          ),
        ),
      ],
    );
  }
}

class albumList extends StatefulWidget {
  final int userid;
  final String username;
  const albumList({required this.userid, required this.username, Key? key})
      : super(key: key);

  @override
  State<albumList> createState() => _albumListState();
}

class _albumListState extends State<albumList> {
  late int userid;
  late String username;

  ScrollController _scrollControllerAlbum =
      ScrollController(); // lazy loading for album

  List<dynamic> albums_to_print = [];

  int pageSize = 10; // Adjust the page size according to your needs
  int currentPageAlbum = 0;

  Future<void> fetchAlbums() async {
    albums_to_print = await AuthService()
        .readUserAlbums(skip: (currentPageAlbum) * pageSize, limit: pageSize);
    setState(() {});
  }

  void _scrollListenerAlbum() {
    if (_scrollControllerAlbum.position.pixels ==
        _scrollControllerAlbum.position.maxScrollExtent) {
      // Reached the bottom of the list, load more albums
      currentPageAlbum++;

      fetchAlbums();
    } else if (_scrollControllerAlbum.position.pixels ==
        _scrollControllerAlbum.position.minScrollExtent) {
      // Reached the top of the list, load previous albums
      if (currentPageAlbum > 0) {
        currentPageAlbum--;
        fetchAlbums();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollControllerAlbum.addListener(_scrollListenerAlbum);

    fetchAlbums().then((_) {
      //searchbar related
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Albums',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                height: 10,
              ),
              for (var global_album in albums_to_print)
                AlbumCard(
                    userid: widget.userid,
                    username: widget.username,
                    album: Album(
                        id: global_album['id'] ?? '',
                        name: global_album['name'] ?? '',
                        artists: global_album['artists'] ?? "[]",
                        artist_ids: global_album['artist_ids'] ?? "[]",
                        number_of_tracks: global_album['number_of_tracks'] ?? 0,
                        explicit: global_album['explicit'] ?? false,
                        danceability: global_album['danceability'] ?? 0,
                        energy: global_album['energy'] ?? 0,
                        key: global_album['key'] ?? 0,
                        loudness: global_album['loudness'] ?? 0,
                        mode: global_album['mode'] ?? 0,
                        speechiness: global_album['speechiness'] ?? 0,
                        acousticness: global_album['acousticness'] ?? 0,
                        instrumentalness: global_album['instrumentalness'] ?? 0,
                        liveness: global_album['liveness'] ?? 0,
                        valence: global_album['valence'] ?? 0,
                        tempo: global_album['tempo'] ?? 0,
                        duration_ms: global_album['duration_ms'] ?? 0,
                        time_signature: global_album['time_signature'] ?? 0,
                        year: global_album['year'] ?? 0,
                        month: global_album['month'] ?? 0,
                        day: global_album['day'] ?? 0,
                        owner_id: global_album['owner_id'] ?? 0)),

              if(albums_to_print.isEmpty)
                Text('No albums added by ${widget.username}'),
            ],

          ),
        ),
      ],
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
      onTap: () async {
        global_albumId = album
            .id; /////////////////////////////////////////////////////////////////////
        Navigator.pushReplacementNamed(context, '/albumPage', arguments: {
          'albumId': album.id,
          'userid': userid,
          'username': username
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
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
                color: album.getVibeColor_energy(),
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
          SizedBox(height: 4.0),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '  ' +
                      (album.name.length > 150
                          ? album.name.substring(0, 15)
                          : album.name),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '  ' +
                      (album.artists[0].length > 15
                          ? album.artists[0].toString().substring(0, 15)
                          : album.artists[0]),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
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

  SongCard({required this.userid, required this.username, required this.song});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        global_songId = song
            .id; /////////////////////////////////////////////////////////////////////////
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
          SizedBox(
              height: 4.0), // Adjust the spacing between the box and the text
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '  ' +
                      (song.name.length > 20
                          ? song.name.substring(0, 15)
                          : song.name),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '  ' +
                      (song.album.length > 20
                          ? song.album.substring(0, 15)
                          : song.album),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

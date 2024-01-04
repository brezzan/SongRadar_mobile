
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'package:songradar/variables.dart';

class mainAppPage extends StatefulWidget {
  final int userid;
  final String username;
  const mainAppPage({required this.userid, required this.username, Key? key})
      : super(key: key);

  @override
  State<mainAppPage> createState() => _mainAppPageState();
}

class _mainAppPageState extends State<mainAppPage> {
  late int userid;
  late String username;
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> filteredSongs = [];

  late Future<Map<String, dynamic>>currentUser; // for printing username after getting id in arguments
  late int count;
  List<Map<String, dynamic>> songs_to_print = [];
  List<Map<String, dynamic>> albums_to_print = [];
  bool isSearchActive = false;

  Future<void> fetchAlbums() async {
    setState(() {
      global_songs = AuthService().getSongsFromCsv();
      global_albums = AuthService().getAlbumsFromCsv();
    });

    songs_to_print = await AuthService().getSongsFromCsv();
    albums_to_print = await AuthService().getAlbumsFromCsv();

    print(songs_to_print);
    print("----");
    print("all songs printed:   ");
    print(global_songs);
    print("----");
    print("all albums printed:   ");
    print(global_albums);
    print("----");

  }

  void search(String query) async {
    isSearchActive = query.isNotEmpty;

    if (!isSearchActive) {
      setState(() {
        filteredSongs = [];
      });
      return;
    }

    if (query.isEmpty) {
      setState(() {
        filteredSongs = songs_to_print;
      });
      return;
    }

    try {
      var response = await AuthService().getSongByNameFromCsv(query);
      if (response.containsKey('error')) {
        print("Error fetching songs: ${response['error']}");
      } else {
        List<Map<String, dynamic>> _tempFilteredSongs = List<Map<String, dynamic>>.from(response['songs']);
        setState(() {
          filteredSongs = _tempFilteredSongs;
        });
      }
    } catch (error) {
      print('Error: $error');
    }
  }




  Future<void> count_album() async {
    count = await AuthService().getSongCountFromCsv();
    print("song count: $count");
  }

  @override
  void initState() {
    super.initState();
    fetchAlbums();

    fetchAlbums().then((_) {
      setState(() {
        filteredSongs = songs_to_print;
      });
    });
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
          children: [
            Text('Welcome, $username'),
            Flexible(
              child: SizedBox(width: 200),
            ),
            IconButton(
              icon: Icon(
                Icons.music_note,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/addNewSong',
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  hintText: 'Search for songs',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
                onChanged: (value) => search(value),
              ),
            ),

            if (isSearchActive)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredSongs.length,
                itemBuilder: (context, index) {
                  var song = filteredSongs[index];
                  return ListTile(
                    title: Text(song['name']),
                    subtitle: Text(song['artists']),
                    /*onTap: () {
                      global_songId=  song.id;         /////////////////////////////////////////////////////////////////////////
                      Navigator.pushReplacementNamed(context, '/songPage', arguments: {
                        'userid': userid,
                        'username': username,
                        'songId': song.id
                      });
                      );
                    },*/
                  );
                },
              ),
            SizedBox(height: 40),
            Text(
              'Recently Favorited -NOT IMPLEMENTED',
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 80),
            Text(
              'Recommended -NOT IMPLEMENTED',
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 80),
            Text(
              'Discover new Songs',
              textAlign: TextAlign.left,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var global_song in songs_to_print)

                    SongCard(
                        userid: userid,
                        username: username,
                        song: Song(
                            id: global_song['id'],
                            name: global_song['name'],
                            album: global_song['album'],
                            album_id: global_song['album_id'],
                            artists: global_song['artists'],
                            artist_ids: global_song['artist_ids'],
                            track_number: global_song['track_number'],
                            disc_number: global_song['disc_number'],
                            explicit: global_song['explicit'],
                            danceability: global_song['danceability'],
                            energy: global_song['energy'],
                            key: global_song['key'],
                            loudness: global_song['loudness'],
                            mode: global_song['mode'],
                            speechiness: global_song['speechiness'],
                            acousticness: global_song['acousticness'],
                            instrumentalness: global_song['instrumentalness'],
                            liveness: global_song['liveness'],
                            valence: global_song['valence'],
                            tempo: global_song['tempo'],
                            duration_ms: global_song['duration_ms'],
                            time_signature: global_song['time_signature'],
                            year: global_song['year'],
                            month: global_song['month'],
                            day: global_song['day'],
                            owner_id: global_song['owner_id']))
                ],
              ),
            ),
            SizedBox(height: 80),
            Text(
              'Discover new Albums',
              textAlign: TextAlign.left,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var global_album in albums_to_print)

                    AlbumCard(
                        userid: userid,
                        username: username,
                        album: Album(
                            id: global_album['id'],
                            name: global_album['name'],
                            artists: global_album['artists'],
                            artist_ids: global_album['artist_ids'],
                            number_of_tracks: global_album['number_of_tracks'],
                            explicit: global_album['explicit'],
                            danceability: global_album['danceability'],
                            energy: global_album['energy'],
                            key: global_album['key'],
                            loudness: global_album['loudness'],
                            mode: global_album['mode'],
                            speechiness: global_album['speechiness'],
                            acousticness: global_album['acousticness'],
                            instrumentalness: global_album['instrumentalness'],
                            liveness: global_album['liveness'],
                            valence: global_album['valence'],
                            tempo: global_album['tempo'],
                            duration_ms: global_album['duration_ms'],
                            time_signature: global_album['time_signature'],
                            year: global_album['year'],
                            month: global_album['month'],
                            day: global_album['day'],
                            owner_id: global_album['owner_id']))
                ],
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120, // Set the desired height for the box
            width: 120, // Set the desired width for the box
            child: Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'Album Cover', // You can replace this with actual album cover widget
                  style: TextStyle(fontSize: 12), // Set the desired font size
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
                  '   ' + album.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '   ' + album.artists,// Joining artists with a comma and space
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
        global_songId=  song.id;         /////////////////////////////////////////////////////////////////////////
        print('songid is ${song.id}');
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
            height: 120, // Set the desired height for the box
            width: 120, // Set the desired width for the box
            child: Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'Album Cover', // You can replace this with actual album cover widget
                  style: TextStyle(fontSize: 12), // Set the desired font size
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
                  '   ' + song.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '   ' + song.album,
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
/*
class AlbumList extends StatefulWidget {
  final String username;
  final int userid;


  AlbumList({required this.userid, required this.username});

  @override
  _AlbumListState createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList> {
  late int count ;
  late String username;
  late int userid;

  late ScrollController _scrollController;
  late List<Map<String, dynamic>> displayedAlbums;
  int albumsPerPage = 30;


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    displayedAlbums = [];
    _loadNextPage();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // User reached the end of the list, load more albums
      _loadNextPage();
    }
  }

  void _loadNextPage() {
    int endIndex = displayedAlbums.length + albumsPerPage;

    if (endIndex > albums_to_print.length) {
      endIndex = albums_to_print.length;
    }

    setState(() {
      displayedAlbums.addAll(albums_to_print.getRange(displayedAlbums.length, endIndex));
    });
  }

  Future<void> count_album() async {
    count = await AuthService().getSongCountFromCsv();
    print("song count: $count");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userid = int.parse('${arguments?['userid']}');
    username = '${arguments?['username']}';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Row(
        children: [
          for (var global_album in displayedAlbums)
            AlbumCard(
                userid: userid,
                username: username,
                album: Album(
                    id: global_album['id'],
                    name: global_album['name'],
                    artists: global_album['artists'],
                    artist_ids: global_album['artist_ids'],
                    number_of_tracks: global_album['number_of_tracks'],
                    explicit: global_album['explicit'],
                    danceability: global_album['danceability'],
                    energy: global_album['energy'],
                    key: global_album['key'],
                    loudness: global_album['loudness'],
                    mode: global_album['mode'],
                    speechiness: global_album['speechiness'],
                    acousticness: global_album['acousticness'],
                    instrumentalness: global_album['instrumentalness'],
                    liveness: global_album['liveness'],
                    valence: global_album['valence'],
                    tempo: global_album['tempo'],
                    duration_ms: global_album['duration_ms'],
                    time_signature: global_album['time_signature'],
                    year: global_album['year'],
                    month: global_album['month'],
                    day: global_album['day'],
                    owner_id: global_album['owner_id'])),
        ],
      ),
    );
  }

}


SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var global_song in songs_to_print)

                          SongCard(
                              userid: userid,
                              username: username,
                              song: Song(
                                  id: global_song['id'],
                                  name: global_song['name'],
                                  album: global_song['album'],
                                  album_id: global_song['album_id'],
                                  artists: global_song['artists'],
                                  artist_ids: global_song['artist_ids'],
                                  track_number: global_song['track_number'],
                                  disc_number: global_song['disc_number'],
                                  explicit: global_song['explicit'],
                                  danceability: global_song['danceability'],
                                  energy: global_song['energy'],
                                  key: global_song['key'],
                                  loudness: global_song['loudness'],
                                  mode: global_song['mode'],
                                  speechiness: global_song['speechiness'],
                                  acousticness: global_song['acousticness'],
                                  instrumentalness: global_song['instrumentalness'],
                                  liveness: global_song['liveness'],
                                  valence: global_song['valence'],
                                  tempo: global_song['tempo'],
                                  duration_ms: global_song['duration_ms'],
                                  time_signature: global_song['time_signature'],
                                  year: global_song['year'],
                                  month: global_song['month'],
                                  day: global_song['day'],
                                  owner_id: global_song['owner_id']))
                      ],
                    ),
                  ),
            SizedBox(height: 80),
            Text(
              'Discover new Albums',
              textAlign: TextAlign.left,
            ),
           SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var global_album in albums_to_print)

                          AlbumCard(
                              userid: userid,
                              username: username,
                              album: Album(
                                  id: global_album['id'],
                                  name: global_album['name'],
                                  artists: global_album['artists'],
                                  artist_ids: global_album['artist_ids'],
                                  number_of_tracks: global_album['number_of_tracks'],
                                  explicit: global_album['explicit'],
                                  danceability: global_album['danceability'],
                                  energy: global_album['energy'],
                                  key: global_album['key'],
                                  loudness: global_album['loudness'],
                                  mode: global_album['mode'],
                                  speechiness: global_album['speechiness'],
                                  acousticness: global_album['acousticness'],
                                  instrumentalness: global_album['instrumentalness'],
                                  liveness: global_album['liveness'],
                                  valence: global_album['valence'],
                                  tempo: global_album['tempo'],
                                  duration_ms: global_album['duration_ms'],
                                  time_signature: global_album['time_signature'],
                                  year: global_album['year'],
                                  month: global_album['month'],
                                  day: global_album['day'],
                                  owner_id: global_album['owner_id']))
                      ],
                    ),
                  ),
                  */


/*    future içerir
FutureBuilder(
              future: global_songs,
              builder: (context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While data is being fetched, you can show a loading indicator
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // If an error occurs during data fetching
                  return Text('Error loading albums');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // If no albums are available
                  return Text('No albums found');
                } else {
                  // Data has been successfully fetched, build the list of AlbumCards
                  List<Map<String, dynamic>> global_songs = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var global_song in global_songs)

                          SongCard(
                              userid: userid,
                              username: username,
                              song: Song(
                                  id: global_song['id'],
                                  name: global_song['name'],
                                  album: global_song['album'],
                                  album_id: global_song['album_id'],
                                  artists: global_song['artists'],
                                  artist_ids: global_song['artist_ids'],
                                  track_number: global_song['track_number'],
                                  disc_number: global_song['disc_number'],
                                  explicit: global_song['explicit'],
                                  danceability: global_song['danceability'],
                                  energy: global_song['energy'],
                                  key: global_song['key'],
                                  loudness: global_song['loudness'],
                                  mode: global_song['mode'],
                                  speechiness: global_song['speechiness'],
                                  acousticness: global_song['acousticness'],
                                  instrumentalness: global_song['instrumentalness'],
                                  liveness: global_song['liveness'],
                                  valence: global_song['valence'],
                                  tempo: global_song['tempo'],
                                  duration_ms: global_song['duration_ms'],
                                  time_signature: global_song['time_signature'],
                                  year: global_song['year'],
                                  month: global_song['month'],
                                  day: global_song['day'],
                                  owner_id: global_song['owner_id']))
                      ],
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 80),
            Text(
              'Discover new Albums',
              textAlign: TextAlign.left,
            ),
            FutureBuilder(
              future: global_albums,
              builder: (context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While data is being fetched, you can show a loading indicator
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // If an error occurs during data fetching
                  return Text('Error loading albums');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // If no albums are available
                  return Text('No albums found');
                } else {
                  // Data has been successfully fetched, build the list of AlbumCards
                  List<Map<String, dynamic>> global_albums = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var global_album in global_albums)

                          AlbumCard(
                              userid: userid,
                              username: username,
                              album: Album(
                                  id: global_album['id'],
                                  name: global_album['name'],
                                  artists: global_album['artists'],
                                  artist_ids: global_album['artist_ids'],
                                  number_of_tracks: global_album['number_of_tracks'],
                                  explicit: global_album['explicit'],
                                  danceability: global_album['danceability'],
                                  energy: global_album['energy'],
                                  key: global_album['key'],
                                  loudness: global_album['loudness'],
                                  mode: global_album['mode'],
                                  speechiness: global_album['speechiness'],
                                  acousticness: global_album['acousticness'],
                                  instrumentalness: global_album['instrumentalness'],
                                  liveness: global_album['liveness'],
                                  valence: global_album['valence'],
                                  tempo: global_album['tempo'],
                                  duration_ms: global_album['duration_ms'],
                                  time_signature: global_album['time_signature'],
                                  year: global_album['year'],
                                  month: global_album['month'],
                                  day: global_album['day'],
                                  owner_id: global_album['owner_id']))
                      ],
                    ),
                  );
                }
              },
            ),
 */
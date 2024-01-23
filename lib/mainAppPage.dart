import 'package:flutter/material.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'package:songradar/variables.dart';


List<dynamic> filteredSongs = [];
List<dynamic> filteredAlbums = [];

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
  TextEditingController searchController =
      TextEditingController(); //searchbar related
  ScrollController _scrollControllerSong =
      ScrollController(); // lazy loading for album
  ScrollController _scrollControllerAlbum =
      ScrollController(); // lazy loading for album

  late Future<Map<String, dynamic>>
      currentUser; // for printing username after getting id in arguments
  late int count;
  List<Map<String, dynamic>> songs_to_print = [];
  List<Map<String, dynamic>> albums_to_print = [];

  bool isSearchActive = false;

  int pageSize = 30; // Adjust the page size according to your needs
  int currentPageAlbum = 1;
  int currentPageSong = 1;

  Future<void> fetchAlbums() async {
    albums_to_print = await AuthService().getAlbumsFromCsv(
        skip: (currentPageAlbum - 1) * pageSize, limit: pageSize);
    setState(() {});
  }

  Future<void> fetchSongs() async {
    songs_to_print = await AuthService().getSongsFromCsv(
        skip: (currentPageAlbum - 1) * pageSize, limit: pageSize);
    setState(() {});
  }

  //searchbar related
  void search(String query) async {
    isSearchActive = query.isNotEmpty;

    if (!isSearchActive) {
      setState(() {
        filteredSongs = [];
        filteredAlbums = [];
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
      List<dynamic> response = await AuthService().getSongByName(query);
      List<dynamic> response_2 = await AuthService().getAlbumByName(query);

      setState(() {
        filteredSongs = response + response_2;
        filteredAlbums = response_2;
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  void _scrollListenerAlbum() {
    if (_scrollControllerAlbum.position.pixels ==
        _scrollControllerAlbum.position.maxScrollExtent) {
      // Reached the bottom of the list, load more albums
      currentPageAlbum++;
      fetchAlbums();
    }
  }

  void _scrollListenerSong() {
    if (_scrollControllerSong.position.pixels ==
        _scrollControllerSong.position.maxScrollExtent) {
      // Reached the bottom of the list, load more albums
      currentPageSong++;
      fetchSongs();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollControllerAlbum.addListener(_scrollListenerAlbum);
    _scrollControllerSong.addListener(_scrollListenerSong);

    fetchSongs();
    fetchAlbums().then((_) {
      //searchbar related
      setState(() {
        filteredSongs = songs_to_print;
        filteredAlbums = albums_to_print;
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
        backgroundColor: Colors.grey,
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
                  IconData iconData;
                  var song = filteredSongs[index];
                  if (song['album_id'] == null) {
                    iconData = Icons.album;
                  } else {
                    // Album
                    iconData = Icons.music_note;
                  }
                  return ListTile(
                    leading: Icon(iconData),
                    title: Text(song['name']),
                    subtitle: Text(song['artists']),
                    onTap: () {
                      if (song['album_id'] == null) {
                        global_albumId = song['id'];
                        Navigator.pushReplacementNamed(context, '/albumPage',
                            arguments: {
                              'albumId': song['id'],
                              'userid': userid,
                              'username': username,
                            });
                      } else {
                        global_songId = song['id'];
                        Navigator.pushReplacementNamed(context, '/songPage',
                            arguments: {
                              'userid': userid,
                              'username': username,
                              'songId': song['id'],
                            });
                      }
                    },
                  );
                },
              ),
            SizedBox(height: 40),
            favorites(userid: userid, username: username),
            SizedBox(height: 80),
            recommends(userid: userid, username: username),
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
                      (album.name.length > 20
                          ? album.name.substring(0, 15)
                          : album.name),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '  ' +
                      (album.artists[0].length > 20
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

class favorites extends StatefulWidget {
  final int userid;
  final String username;
  const favorites({required this.userid, required this.username, Key? key})
      : super(key: key);

  @override
  State<favorites> createState() => _favoritesState();
}

class _favoritesState extends State<favorites> {
  late int userid;
  late String username;

  late Future<Map<String, dynamic>>
      currentUser; // for printing username after getting id in arguments

  List<dynamic> starredSongs_to_print = [];

  Future<void> fetchStarred() async {
    starredSongs_to_print = await AuthService().getStarred();
    setState(() {});
  }

  @override
  void initState() {
    fetchStarred();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Favorite Songs',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.left,
        ),
        SizedBox(height:10),
        if (starredSongs_to_print.isEmpty)
          Text(
            'Start favoriting songs',
            style: TextStyle(fontSize: 20),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var starredSong in starredSongs_to_print)
                  SongCard(
                      userid: widget.userid,
                      username: widget.username,
                      song: Song(
                          id: starredSong['id'] ?? '',
                          name: starredSong['name'] ?? '',
                          album: starredSong['album'] ?? '',
                          album_id: starredSong['album_id'] ?? '',
                          artists: starredSong['artists'] ?? '[]',
                          artist_ids: starredSong['artist_ids'] ?? '[]',
                          track_number: 0,
                          disc_number: 0,
                          explicit: starredSong['explicit'] ?? false,
                          danceability: starredSong['danceability'] ?? 0,
                          energy: starredSong['energy'] ?? 0,
                          key: starredSong['key'] ?? 0,
                          loudness: starredSong['loudness'] ?? 0,
                          mode: starredSong['mode'] ?? 0,
                          speechiness: starredSong['speechiness'] ?? 0,
                          acousticness: starredSong['acousticness'] ?? 0,
                          instrumentalness:
                              starredSong['instrumentalness'] ?? 0,
                          liveness: starredSong['liveness'] ?? 0,
                          valence: starredSong['valence'] ?? 0,
                          tempo: starredSong['tempo'] ?? 0,
                          duration_ms: starredSong['duration_ms'] ?? 0,
                          time_signature: starredSong['time_signature'] ?? 0,
                          year: starredSong['year'] ?? 0,
                          month: starredSong['month'] ?? 0,
                          day: starredSong['day'] ?? 0,
                          owner_id: starredSong['owner_id'] ?? 0))
              ],
            ),
          ),
      ],
    );
  }
}

class recommends extends StatefulWidget {
  final int userid;
  final String username;
  const recommends({required this.userid, required this.username, Key? key})
      : super(key: key);
  @override
  State<recommends> createState() => _recommendsState();
}

class _recommendsState extends State<recommends> {
  late int userid;
  late String username;

  ScrollController _scrollControllerRecommended = ScrollController();

  List<Map<String, dynamic>> recommendeds = [];


  Future<void> fetchRecommend() async {
      recommendeds= await AuthService().recommendFromStarred();
      print(recommendeds.length);
    setState(() {});
  }

  void _scrollListenerRecommended() {
    if (_scrollControllerRecommended.position.pixels ==
        _scrollControllerRecommended.position.maxScrollExtent) {
        fetchRecommend();
        setState(() {
          // Update the state after recommendations are fetched
        });
    } else if (_scrollControllerRecommended.position.pixels ==
        _scrollControllerRecommended.position.minScrollExtent) {
        fetchRecommend();
        setState(() {
          // Update the state after recommendations are fetched
        });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollControllerRecommended.addListener(_scrollListenerRecommended);
      setState(() {
        fetchRecommend();
      });

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Recommended ',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.left,
        ),
        SizedBox(height:10),
        if (recommendeds.length == 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: Text(
                'Start favoriting for recommendations',
                style: TextStyle(fontSize: 20),
              )),
            ],
          )
        else
          SingleChildScrollView(
            controller: _scrollControllerRecommended,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var starredSong in recommendeds)
                  SongCard(
                      userid: widget.userid,
                      username: widget.username,
                      song: Song(
                          id: starredSong['id'] ?? '',
                          name: starredSong['name'] ?? '',
                          album: starredSong['album'] ?? '',
                          album_id: starredSong['album_id'] ?? '',
                          artists: starredSong['artists'] ?? '[]',
                          artist_ids: starredSong['artist_ids'] ?? '[]',
                          track_number: 0,
                          disc_number: 0,
                          explicit: starredSong['explicit'] ?? false,
                          danceability: starredSong['danceability'] ?? 0,
                          energy: starredSong['energy'] ?? 0,
                          key: starredSong['key'] ?? 0,
                          loudness: starredSong['loudness'] ?? 0,
                          mode: starredSong['mode'] ?? 0,
                          speechiness: starredSong['speechiness'] ?? 0,
                          acousticness: starredSong['acousticness'] ?? 0,
                          instrumentalness:
                              starredSong['instrumentalness'] ?? 0,
                          liveness: starredSong['liveness'] ?? 0,
                          valence: starredSong['valence'] ?? 0,
                          tempo: starredSong['tempo'] ?? 0,
                          duration_ms: starredSong['duration_ms'] ?? 0,
                          time_signature: starredSong['time_signature'] ?? 0,
                          year: starredSong['year'] ?? 0,
                          month: starredSong['month'] ?? 0,
                          day: starredSong['day'] ?? 0,
                          owner_id: starredSong['owner_id'] ?? 0))
              ],
            ),
          ),
      ],
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

  List<Map<String, dynamic>> songs_to_print = [];

  int pageSize = 30; // Adjust the page size according to your needs

  int currentPageSong = 1;

  Future<void> fetchSongs() async {
    songs_to_print = await AuthService().getSongsFromCsv(
        skip: (currentPageSong - 1) * pageSize, limit: pageSize);
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
      setState(() {
        filteredSongs = songs_to_print;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Discover new Songs',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.left,
        ),
        SizedBox(height:10),
        SingleChildScrollView(
          controller: _scrollControllerSong,
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
                        instrumentalness:
                        global_song['instrumentalness'] ?? 0,
                        liveness: global_song['liveness'] ?? 0,
                        valence: global_song['valence'] ?? 0,
                        tempo: global_song['tempo'] ?? 0,
                        duration_ms: global_song['duration_ms'] ?? 0,
                        time_signature: global_song['time_signature'] ?? 0,
                        year: global_song['year'] ?? 0,
                        month: global_song['month'] ?? 0,
                        day: global_song['day'] ?? 0,
                        owner_id: global_song['owner_id'] ?? 0))
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

  List<Map<String, dynamic>> albums_to_print = [];

  int pageSize = 30; // Adjust the page size according to your needs
  int currentPageAlbum = 0;

  Future<void> fetchAlbums() async {
    albums_to_print = await AuthService()
        .getAlbumsFromCsv(skip: (currentPageAlbum) * pageSize, limit: pageSize);
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
      setState(() {
        filteredAlbums = albums_to_print;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Discover new Albums',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.left,
        ),
        SizedBox(height:10),
        SingleChildScrollView(
          controller: _scrollControllerAlbum,
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
                        artists: global_album['artists']?? "[]",
                        artist_ids: global_album['artist_ids']?? "[]",
                        number_of_tracks: global_album['number_of_tracks'] ?? 0,
                        explicit: global_album['explicit']?? false,
                        danceability: global_album['danceability'] ?? 0,
                        energy: global_album['energy']?? 0,
                        key: global_album['key']?? 0,
                        loudness: global_album['loudness']?? 0,
                        mode: global_album['mode']?? 0,
                        speechiness: global_album['speechiness']?? 0,
                        acousticness: global_album['acousticness']?? 0,
                        instrumentalness: global_album['instrumentalness']?? 0,
                        liveness: global_album['liveness']?? 0,
                        valence: global_album['valence']?? 0,
                        tempo: global_album['tempo']?? 0,
                        duration_ms: global_album['duration_ms']?? 0,
                        time_signature: global_album['time_signature']?? 0,
                        year: global_album['year']?? 0,
                        month: global_album['month'] ?? 0,
                        day: global_album['day']?? 0,
                        owner_id: global_album['owner_id']?? 0 ))
            ],
          ),
        ),
      ],
    );
  }
}



// old mainAppPage
/*List<dynamic> filteredSongs = [];
List<dynamic> filteredAlbums = [];

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
  TextEditingController searchController = TextEditingController(); //searchbar related
  ScrollController _scrollControllerRecommended = ScrollController();
  ScrollController _scrollControllerAlbum = ScrollController(); // lazy loading for album
  ScrollController _scrollControllerSong = ScrollController(); // lazy loading for album

  late Future<Map<String, dynamic>> currentUser; // for printing username after getting id in arguments
  late int count;
  List<Map<String, dynamic>>  songs_to_print = [];
  List<Map<String, dynamic>> albums_to_print = [];
  List<dynamic> starredSongs_to_print = [];
  List<dynamic> recommendeds = [];

  bool isSearchActive = false;

  int pageSize = 30; // Adjust the page size according to your needs
  int currentPageAlbum = 1;
  int currentPageSong = 1;


  Future<void> fetchAlbums() async {

    albums_to_print = await AuthService().getAlbumsFromCsv(skip: (currentPageAlbum - 1) * pageSize, limit: pageSize);
    setState(() {
    });

  }

  Future<void> fetchSongs() async {
    songs_to_print = await AuthService().getSongsFromCsv(skip: (currentPageAlbum - 1) * pageSize, limit: pageSize);
    setState(() {

    });
  }

  Future<void> fetchStarred()async{
    starredSongs_to_print = await AuthService().getStarred();
    setState(() {
    });
  }

  Future<void> fetchRecommend() async {
    print('length of favorites ${starredSongs_to_print}');
    Random random = Random();
    for (int i = 0; i < 3; i++) {
      int randomIndex = random.nextInt(starredSongs_to_print.length);
      List<Map<String, dynamic>> recs = await AuthService().recommend(starredSongs_to_print[randomIndex]['id'], recommend: 10);
      recommendeds.addAll(recs);
    }
    setState(() {
    });
  }



  //searchbar related
  void search(String query) async {
    isSearchActive = query.isNotEmpty;

    if (!isSearchActive) {
      setState(() {
        filteredSongs = [];
        filteredAlbums= [];
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
      List<dynamic> response = await AuthService().getSongByName(query);
      List<dynamic> response_2 = await AuthService().getAlbumByName(query);

      setState(() {
        filteredSongs = response + response_2;
        filteredAlbums = response_2;
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  // lazy loading related
  void _scrollListenerRecommended() {
    if (_scrollControllerRecommended.position.pixels == _scrollControllerRecommended.position.maxScrollExtent) {
      // Reached the bottom of the list, load more recommendations if available
      if (starredSongs_to_print.isNotEmpty) {
        fetchRecommend();
        setState(() {
        });
      }
      else{
        print('stared is empty');
        fetchStarred();
        fetchRecommend();
        setState(() {
          // Update the state after recommendations are fetched
        });
      }
    }
  }

  void _scrollListenerAlbum() {
    if (_scrollControllerAlbum.position.pixels == _scrollControllerAlbum.position.maxScrollExtent) {
      // Reached the bottom of the list, load more albums
      currentPageAlbum++;
      fetchAlbums();
    }
  }
  void _scrollListenerSong() {
    if (_scrollControllerSong.position.pixels == _scrollControllerSong.position.maxScrollExtent) {
      // Reached the bottom of the list, load more albums
      currentPageSong++;
      fetchSongs();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollControllerAlbum.addListener(_scrollListenerAlbum);
    _scrollControllerSong.addListener(_scrollListenerSong);
    _scrollControllerRecommended.addListener(_scrollListenerRecommended);
    fetchStarred().then((_){
      setState(() {
      fetchRecommend();
      });
    });
    fetchSongs();
    fetchAlbums().then((_) {//searchbar related
      setState(() {
        filteredSongs = songs_to_print;
        filteredAlbums = albums_to_print;
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
                  IconData iconData;
                  var song = filteredSongs[index];
                  if (song['album_id'] == null) {
                    iconData = Icons.album;

                  } else {
                    // Album
                    iconData = Icons.music_note;
                  }
                  return ListTile(
                    leading: Icon(iconData),
                    title: Text(song['name']),
                    subtitle: Text(song['artists']),
                    onTap: () {
                      if (song['album_id'] == null) {
                        global_albumId = song['id'];
                        Navigator.pushReplacementNamed(context, '/albumPage',
                            arguments: {
                              'albumId': song['id'],
                              'userid': userid,
                              'username': username,
                            });
                      }
                      else {
                        global_songId = song['id'];
                        Navigator.pushReplacementNamed(context, '/songPage',
                            arguments: {
                              'userid': userid,
                              'username': username,
                              'songId': song['id'],
                            });
                      }
                    },
                  );
                },
              ),

            SizedBox(height: 40),
            Text(
              'Favorited',
              textAlign: TextAlign.left,
            ),
            if(starredSongs_to_print.isEmpty)
              Text('Start favoriting songs',style: TextStyle(fontSize: 20),)
            else
              SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var starredSong in starredSongs_to_print)

                    SongCard(
                        userid: userid,
                        username: username,
                        song: Song(
                            id: starredSong['id'],
                            name: starredSong['name'],
                            album: starredSong['album'],
                            album_id: starredSong['album_id'],
                            artists: starredSong['artists'],
                            artist_ids: starredSong['artist_ids'],
                            track_number: 0,
                            disc_number:0,
                            explicit: starredSong['explicit'],
                            danceability: starredSong['danceability'],
                            energy: starredSong['energy'],
                            key: starredSong['key'],
                            loudness: starredSong['loudness'],
                            mode: starredSong['mode'],
                            speechiness: starredSong['speechiness'],
                            acousticness: starredSong['acousticness'],
                            instrumentalness: starredSong['instrumentalness'],
                            liveness: starredSong['liveness'],
                            valence: starredSong['valence'],
                            tempo: starredSong['tempo'],
                            duration_ms: starredSong['duration_ms'],
                            time_signature: starredSong['time_signature'],
                            year: starredSong['year'],
                            month: starredSong['month'],
                            day: starredSong['day'],
                            owner_id: starredSong['owner_id']))
                ],
              ),
            ),
            SizedBox(height: 80),
            Text(
              'Recommended ',
              textAlign: TextAlign.left,
            ),
            if(starredSongs_to_print.isEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: Text('Start favoriting for recommendations',style: TextStyle(fontSize: 20),)),
                ],
              )
            else
              SingleChildScrollView(
                controller: _scrollControllerRecommended,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var starredSong in recommendeds)

                      SongCard(
                          userid: userid,
                          username: username,
                          song: Song(
                              id: starredSong['id'],
                              name: starredSong['name'],
                              album: starredSong['album'],
                              album_id: starredSong['album_id'],
                              artists: starredSong['artists'],
                              artist_ids: starredSong['artist_ids'],
                              track_number: 0,
                              disc_number:0,
                              explicit: starredSong['explicit'],
                              danceability: starredSong['danceability'],
                              energy: starredSong['energy'],
                              key: starredSong['key'],
                              loudness: starredSong['loudness'],
                              mode: starredSong['mode'],
                              speechiness: starredSong['speechiness'],
                              acousticness: starredSong['acousticness'],
                              instrumentalness: starredSong['instrumentalness'],
                              liveness: starredSong['liveness'],
                              valence: starredSong['valence'],
                              tempo: starredSong['tempo'],
                              duration_ms: starredSong['duration_ms'],
                              time_signature: starredSong['time_signature'],
                              year: starredSong['year'],
                              month: starredSong['month'],
                              day: starredSong['day'],
                              owner_id: starredSong['owner_id']))
                  ],
                ),
              ),
            SizedBox(height: 80),
            Text(
              'Discover new Songs',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
            SingleChildScrollView(
              controller: _scrollControllerSong,
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
                            track_number: 0,
                            disc_number:0,
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
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
            SingleChildScrollView(
              controller: _scrollControllerAlbum,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(height: 10,),

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
*/

import 'package:flutter/material.dart';
import 'dart:core';
import 'package:songradar/variables.dart';
import 'package:songradar/api.dart';

class playlistPage extends StatefulWidget {
  final int userid,playlistId;
  final String username;
  const playlistPage({required this.userid, required this.username, required this.playlistId ,Key? key})
      : super(key: key);

  @override
  State<playlistPage> createState() => _playlistPageState();
}

class _playlistPageState extends State<playlistPage> {
  late int userid, playlistId;
  late String username;
  TextEditingController playlist_name =  TextEditingController(text: global_playlist_name);
  List<Map<String, dynamic>> songs_to_be_added = [];
  Map<String,dynamic> playlist_info = {};

  TextEditingController searchController =
  TextEditingController(); //searchbar related

  List<dynamic> filteredSongs = [];
  List<dynamic> filteredAlbums = [];

  List<Map<String, dynamic>> songs_to_print = [];
  List<Map<String, dynamic>> albums_to_print = [];
  bool isSearchActive = false;

  int pageSize = 30; // Adjust the page size according to your needs
  int currentPageAlbum = 1;
  int currentPageSong = 1;

  Future<void> info() async {
    playlist_info = await fetchPlaylist();
  }

  Future<Map<String,dynamic>> fetchPlaylist() async {
    return await AuthService().getPlaylistById(global_playlist);
  }

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

      setState(() {
        filteredSongs = response;
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> fetchAlbums() async {
    setState(() {
      global_songs = AuthService().getSongsFromCsv(
          skip: (currentPageAlbum - 1) * pageSize, limit: pageSize);
      global_albums = AuthService().getAlbumsFromCsv(
          skip: (currentPageAlbum - 1) * pageSize, limit: pageSize);
    });

    songs_to_print = await AuthService().getSongsFromCsv(
        skip: (currentPageAlbum - 1) * pageSize, limit: pageSize);
    albums_to_print = await AuthService().getAlbumsFromCsv(
        skip: (currentPageAlbum - 1) * pageSize, limit: pageSize);
  }

  @override
  void initState() {
    super.initState();
    info();
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
    playlistId = int.parse('${arguments?['playlistId']}');

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
                  child: Text('Playlist: $global_playlist_name'),
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
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(height: 30),
            TextField(
              controller: playlist_name,
              decoration: InputDecoration(
                icon: Icon(Icons.album_sharp),
                hintText: 'Playlist Name',

              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search to Add Songs',
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
                      if (song['album_id'] != null) {
                        songs_to_be_added.add(song);
                      }
                    },
                  );
                },
              ),
            SizedBox(height: 50),

            Builder(
              builder: (BuildContext context) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: songs_to_be_added.length,
                  itemBuilder: (context, index) {
                    IconData iconData = Icons.music_note;
                    var song = songs_to_be_added[index];

                    return ListTile(
                      leading: Icon(iconData),
                      tileColor: Colors.green[100],
                      title: Text(song['name']),
                      subtitle: Text(song['artists']),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            songs_to_be_added.remove(song);
                          });
                        },
                        icon: Icon(Icons.delete),
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 50),

            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: FutureBuilder(
                future: fetchPlaylist(),
                builder: (BuildContext context, AsyncSnapshot<Map<String,dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    Map<String,dynamic> playlist = snapshot.data ?? {};

                    return Container(

                      height: 200, // You can adjust the height as needed
                      child: ListView.builder(
                        itemCount: playlist['songs'].length,
                        itemBuilder: (context, index) {
                          IconData iconData = Icons.music_note;
                          var song = playlist['songs'][index];

                          return ListTile(

                            leading: Icon(iconData),
                            tileColor: Colors.grey[200],
                            title: Text(song['name']),
                            trailing: IconButton(
                              onPressed: () async {
                                await AuthService().deleteSongFromPlaylist(song['id'],global_playlist);
                                setState(() {

                                });
                              },
                              icon: Icon(Icons.delete),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 50),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {

                await AuthService().renamePlaylist(global_playlist,playlist_name.text);
                for (var song in songs_to_be_added) {
                  await AuthService().putToPlaylist(song['id'], global_playlist);

                }
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Playlist : ${playlist_name.text} got updated '),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/personalPage', arguments: {
                              'userid': userid,
                              'username': username
                            });
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('UPDATE PLAYLIST'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:core';
import 'package:songradar/variables.dart';
import 'package:songradar/api.dart';

class createPlaylist extends StatefulWidget {
  final int userid;
  final String username;
  const createPlaylist({required this.userid, required this.username, Key? key})
      : super(key: key);

  @override
  State<createPlaylist> createState() => _createPlaylistState();
}

class _createPlaylistState extends State<createPlaylist> {
  late int userid;
  late String username;
  TextEditingController playlist_name = TextEditingController();
  List<Map<String, dynamic>> songs_to_be_added = [];

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
                  child: Text('Create A New Playlist'),
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
          children: [
            SizedBox(height: 30),
            TextField(
              controller: playlist_name,
              decoration: InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'Playlist Name',
              ),
            ),
            SizedBox(height: 30),
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
                      tileColor: Colors.green[300],
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                Map<String, dynamic> playlist_info =
                    await AuthService().createPlaylist(playlist_name.text);
                int p_id = playlist_info['id'];
                int added_count = 0;
                for (var song in songs_to_be_added) {
                  await AuthService().putToPlaylist(song['id'], p_id);
                  added_count++;
                }
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                          'Playlist : ${playlist_name.text} got created '),
                      content: Text('$added_count many songs were added '),
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
              child: Text('CREATE PLAYLIST'),
            ),
          ],
        ),
      ),
    );
  }
}

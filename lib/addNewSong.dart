import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:songradar/api.dart';
import 'dart:core';
import 'dart:convert';
import 'package:songradar/signup.dart';
import 'package:songradar/mainAppPage.dart';

class addNewSong extends StatefulWidget {
  final String username;
  const addNewSong({required this.username, Key? key}) : super(key: key);

  @override
  State<addNewSong> createState() => _addNewSongState();
}

class _addNewSongState extends State<addNewSong> {
  late String username;

  TextEditingController title = TextEditingController();
  TextEditingController performers = TextEditingController();
  String year = '';
  TextEditingController genre = TextEditingController();
  TextEditingController album = TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    username = '${arguments?['username']}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Row(
          children: [
            Text('Add a New Song'),
            SizedBox(
              width: 180,
            ),
            IconButton(
              icon: Icon(
                Icons.cancel_presentation_rounded,
                size: 40,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/mainAppPage',
                    arguments: {'username': username});
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Flexible (
              child: Row(children: [
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding:
                              EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: BeveledRectangleBorder()),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/addNewSong',
                            arguments: {'username': username});
                      },
                      child: Text('Add Song')),
                ),
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding:
                              EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: BeveledRectangleBorder()),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/addNewAlbum',
                            arguments: {'username': username});
                      },
                      child: Text('Add Album')),
                ),
              ]),
            ),
            SizedBox(height: 15),
            Flexible (
              child: TextField(
                controller: title,
                decoration: InputDecoration(
                  icon: Icon(Icons.music_note),
                  hintText: 'Title of Song',
                ),
              ),
            ),
            SizedBox(height: 15),
            Flexible (
              child: TextField(
                controller: album,
                decoration: InputDecoration(
                  icon: Icon(Icons.album_rounded),
                  hintText: 'Album',
                ),
              ),
            ),
            SizedBox(height: 15),
            Flexible (
              child: TextField(
                controller: performers,
                decoration: InputDecoration(
                  icon: Icon(Icons.people_alt_rounded),
                  hintText: 'Performers',
                ),
              ),
            ),
            SizedBox(height: 15),
            Flexible (
              child: TextFormField(
                // Set the controller
                onChanged: (value) {
                  // Update the new_time_for_brew only when the user modifies the text
                  if (value.isNotEmpty) {
                    year = value;
                  }
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                keyboardType: TextInputType.number, // Show numeric keyboard
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_month_rounded),
                  hintText: 'Publish Year',
                ),
              ),
            ),
            SizedBox(height: 15),
            Flexible (
              child: TextField(
                controller: genre,
                decoration: InputDecoration(
                  icon: Icon(Icons.library_music_rounded),
                  hintText: 'Genre',
                ),
              ),
            ),
            SizedBox(height: 15),
            Flexible (
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: BeveledRectangleBorder(),
                ),
                onPressed: () async {  // once 200 sonra 422 veriyor post fonskiyonunu daha iyi incele
                  try {
                    List<Map<String, dynamic>> albums = await AuthService().getAlbums();

                    int album_id_to_add_to = 0;
                    bool album_exists = false;

                    // Check if the album exists
                    for (var albumLine in albums) {
                      if (albumLine['title'] == album.text &&
                          albumLine['performers'] == performers.text &&
                          albumLine['year'] == int.parse(year) &&
                          albumLine['genre'] == genre.text) {
                        album_id_to_add_to = albumLine['id'];
                        album_exists = true;
                      }
                    }

                    if (!album_exists) {
                      // Add the album first
                      final Map<String, dynamic> newlyAddedAlbum = await AuthService().createAlbum(
                        album.text,
                        performers.text,
                        int.parse(year),
                        genre.text,
                      );

                      // Get the ID of the newly added album
                      album_id_to_add_to = newlyAddedAlbum['id'];
                      print('Song will be added to this album id= $album_id_to_add_to');
                    }

                    // Now that we have the correct album ID, add the song
                    final Map<String, dynamic> newlyAddedSong = await AuthService().createSong(
                      title.text,
                      performers.text,
                      int.parse(year),
                      genre.text,
                      album_id_to_add_to,
                    );

                    if (!newlyAddedSong.containsKey('error')) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                              'Song added to system',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    else{
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Could not add the song'),
                            content: Text( '${newlyAddedSong['detail']}', ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );

                    }

                  } catch (e) {
                    print("Error: $e");
                    // Handle the error as needed
                  }
                },
                child: Text('Add Song'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*
onPressed: () async {  // once 200 sonra 422 veriyor post fonskiyonunu daha iyi incele
                  try {
                    List<Map<String, dynamic>> albums = await AuthService().getAlbums();

                    int album_id_to_add_to = 0;
                    bool album_exists = false;

                    // Check if the album exists
                    for (var albumLine in albums) {
                      if (albumLine['title'] == album.text &&
                          albumLine['performers'] == performers.text &&
                          albumLine['year'] == int.parse(year) &&
                          albumLine['genre'] == genre.text) {
                        album_id_to_add_to = albumLine['id'];
                        album_exists = true;
                      }
                    }

                    if (!album_exists) {
                      // Add the album first
                      final Map<String, dynamic> newlyAddedAlbum = await AuthService().createAlbum(
                        album.text,
                        performers.text,
                        int.parse(year),
                        genre.text,
                      );

                      // Get the ID of the newly added album
                      album_id_to_add_to = newlyAddedAlbum['id'];
                    }

                    // Now that we have the correct album ID, add the song
                    final Map<String, dynamic> newlyAddedSong = await AuthService().createSong(
                      title.text,
                      performers.text,
                      int.parse(year),
                      genre.text,
                      album_id_to_add_to,
                    );

                    if (!newlyAddedSong.containsKey('error')) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                              'Song added to system',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    else{
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Could not add the song'),
                            content: Text( '${newlyAddedSong['detail']}', ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );

                    }

                  } catch (e) {
                    print("Error: $e");
                    // Handle the error as needed
                  }
                },
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:songradar/api.dart';
import 'dart:core';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

import 'package:songradar/signup.dart';
import 'package:songradar/mainAppPage.dart';
import 'dart:io';

class addNewSong extends StatefulWidget {
  final int userid;
  final String username;
  const addNewSong({required this.userid,required this.username, Key? key}) : super(key: key);

  @override
  State<addNewSong> createState() => _addNewSongState();
}

class _addNewSongState extends State<addNewSong> {
  late int userid;
  late String username;

  TextEditingController title = TextEditingController();
  TextEditingController performers = TextEditingController();
  String year = '';
  TextEditingController genre = TextEditingController();
  TextEditingController album = TextEditingController();


  Future<void> addAlbumFromFile(Map<String, dynamic> albumData, int songs_count,int album_count) async {
    String albumTitle = albumData['title'];
    int albumYear = albumData['year'];
    String albumGenre = albumData['genre'];
    String albumPerformers = albumData['performers'];

    List<Map<String, dynamic>> songsData = List<Map<String, dynamic>>.from(albumData['songs']);

    //List<Map<String, dynamic>> albums = await AuthService().getAlbums(); // eklemeden önce album var mı yok mu
    List<Map<String, dynamic>> albums = (await AuthService().getAlbums()) as List<Map<String, dynamic>>;

    bool album_exists = false;
    int album_id_to_add_to = 0;
    List<Map<String, dynamic>> songs_in_that_album = [];

    for (var albumLine in albums) {
      if (albumLine['title'] == albumTitle &&
          albumLine['performers'] == albumPerformers &&
          albumLine['year'] == albumYear &&
          albumLine['genre'] == albumGenre) {

        album_exists = true;
        album_id_to_add_to = albumLine['id'];
        songs_in_that_album = albumLine['songs'] as List<Map<String, dynamic>> ;
      }
    }

    if (!album_exists) {
      final Map<String, dynamic> newlyAddedAlbum = await AuthService().createAlbum(albumTitle, albumPerformers, albumYear,
          albumGenre);

      if (!newlyAddedAlbum.containsKey('error')) {
        print("SUCCESFULLY ADDDED ALBUM");
        album_count ++ ;
        album_id_to_add_to = newlyAddedAlbum['id'];
        songs_in_that_album =  newlyAddedAlbum['songs'];  // album içine aynı şarkıyı eklememk için check etmek için tut

      } else {
        print("CANNOT ADD ALBUM ");

      }
    }
    // album db de yoksa bile artık var

    if (songsData.isNotEmpty) { // album içinde eklenecek şarkı var

      for (var songData in songsData) {
        bool songexists = false;
        String songTitle = songData['title'];   // album ile icindeki song zaten aynı genre year ve performersa sahip, sadece song itle al
        for (var existingsongs in songs_in_that_album) {
          if (existingsongs['title'] ==songTitle && existingsongs['year'] ==albumYear &&
              existingsongs['genre'] ==albumGenre && existingsongs['performers'] ==albumPerformers) {
            songexists = true;
          }
        }

        if(!songexists){
          final Map<String, dynamic> newlyAddedSong = await AuthService().createSong(songTitle, albumPerformers, albumYear, albumGenre,
            album_id_to_add_to,);
          songs_count ++;

          // update songs_in_that_album

        }
      }
    }
  }


  Future<void> addSongFromFile(Map<String, dynamic> songData ,int songs_count,int album_count) async {
    String songTitle = songData['title'];
    int songYear = songData['year'];
    String songGenre = songData['genre'];
    String songPerformers = songData['performers'];

    bool songexists = false;

    if (songData.containsKey('album')) { // bu şarkı bir albüme eklenmeli önce albüm var mı check et , yoksa yarat
      print("songData.containsKey('album'): ${songData.containsKey('album')}");
      String albumTitle = songData['album'];

      //List<Map<String, dynamic>> albums = await AuthService().getAlbums(); // eklemeden önce album var mı yok mu
      List<Map<String, dynamic>> albums = (await AuthService().getAlbums()) as List<Map<String, dynamic>>;

      bool album_exists = false;
      int album_id_to_add_to = 0;
      List<Map<String, dynamic>> songs_in_that_album = [];


      for (var albumLine in albums) {
        if (albumLine['title'] == albumTitle &&
            albumLine['performers'] == songPerformers &&
            albumLine['year'] == songYear &&
            albumLine['genre'] == songGenre) {
          album_exists = true;
          album_id_to_add_to = albumLine['id'];
          songs_in_that_album = albumLine['songs'];

        }
      }

      if (!album_exists) {
        final Map<String, dynamic> newlyAddedAlbum = await AuthService().createAlbum(albumTitle, songPerformers, songYear,
            songGenre); // album var mı yok mu check ediyor mu hatırlamıyorum

        if (!newlyAddedAlbum.containsKey('error')) {
          print("SUCCESFULLY ADDDED ALBUM");
          album_count ++;
          album_id_to_add_to = newlyAddedAlbum['id'];
          songs_in_that_album =  newlyAddedAlbum['songs'] ; // album içine aynı şarkıyı eklememk için check etmek için tut

        } else {
          print("CANNOT ADD ALBUM ");
        }
      }

      for (var existingsongs in songs_in_that_album) {
        if (existingsongs['title'] == songTitle &&
            existingsongs['year'] == songYear && existingsongs['genre'] == songGenre &&
            existingsongs['performers'] == songPerformers) {
          songexists = true;
        }
      }

      if (!songexists) {
        final Map<String, dynamic> newlyAddedSong = await AuthService().createSong(songTitle, songPerformers,  songYear , songGenre,
          album_id_to_add_to,);
        songs_count ++;
      }


    } else { // album title olmadan ekle
      //List<Map<String, dynamic>> songs = await AuthService().getSongs();
      List<Map<String, dynamic>> songs = (await AuthService().getSongs()) as List<Map<String, dynamic>>;
      bool song_exists = false;

      for (var songLine in songs) {
        if (songLine['title'] == songTitle &&
            songLine['performers'] == songPerformers &&
            songLine['year'] == songYear &&
            songLine['genre'] == songGenre) {
          song_exists = true;
        }
      }

      if (!song_exists) {
        int place_holder = 0; // albumsuz olduğu için şuan album_id 0 olacak sekilde kaydet
        final Map<String, dynamic> newlyAddedSong = await AuthService().createSong(
            songTitle, songPerformers, songYear, songGenre, place_holder);
        songs_count ++;
      }
    }
  }

  Future<void> pickAndReadFile(BuildContext context ) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      if (Platform.isIOS || Platform.isAndroid) {
        File pickedFile = File(file.path!);

        String fileContent = await pickedFile.readAsString();

        try {
          int songs_count = 0;
          int albums_count = 0;
          List<dynamic> jsonData = jsonDecode(fileContent);

          for (var element in jsonData) {
            if (element.containsKey('songs')) {  // element to be added is an album
              addAlbumFromFile(element,songs_count,albums_count);
            } else {  // It's a song          // element to be added is a song
              addSongFromFile(element,songs_count,albums_count);
            }
          }
          showDialog(
           context: context ,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(
                  '$albums_count albums and $songs_count songs have been added succesfully ',
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

        } catch (e) {
          print('Error decoding JSON: $e');
        }
      } else {
        print('File picking and dart:io not supported on this platform.');
      }
    } else {
      // User canceled file picking
    }
  }


  @override
  void initState() {
    super.initState();
  }

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
                    arguments: {'userid': userid, 'username':username});
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
                            arguments: {'userid': userid, 'username':username});
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
                      onPressed: ()  {
                        Navigator.pushReplacementNamed(context, '/addNewAlbum',
                            arguments: {'userid': userid, 'username':username});
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

                    if(album.text.isNotEmpty) {
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

                        final Map<String,
                            dynamic> newlyAddedSong = await AuthService()
                            .createSong(
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
                        else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Could not add the song'),
                                content: Text('${newlyAddedSong['detail']}',),
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
                      }

                      else { // album exists
                        List<Map<String, dynamic>> songs = await AuthService()
                            .getSongs();
                        bool song_exists = false;

                        for (var songLine in songs) {
                          if (songLine['title'] == title.text &&
                              songLine['performers'] == performers.text &&
                              songLine['year'] == int.parse(year) &&
                              songLine['genre'] == genre.text &&
                              songLine['id'] == album_id_to_add_to) {
                            song_exists = true;
                          }
                        }

                        if (!song_exists) {
                          final Map<String,
                              dynamic> newlyAddedSong = await AuthService()
                              .createSong(
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
                          else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Could not add the song'),
                                  content: Text('${newlyAddedSong['detail']}',),
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
                        }
                        else { // both song and album exists
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Already in System'),
                                content: Text(
                                    'Both song and the album are already in the system'),
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
                      }
                    }
                    else{    // empty album text , burada elbum id 0 olarak kayıt ediliyor
                            // ileride single olacak şekile aynı adda bir albüm yaratıp onun içibe eklemek gerekebilir
                      List<Map<String, dynamic>> songs = await AuthService()
                          .getSongs();
                      bool song_exists = false;

                      for (var songLine in songs) {
                        if (songLine['title'] == title.text &&
                            songLine['performers'] == performers.text &&
                            songLine['year'] == int.parse(year) &&
                            songLine['genre'] == genre.text ) {
                          song_exists = true;
                        }
                      }

                      if (!song_exists) {
                        int place_holder = 0;
                        final Map<String,
                            dynamic> newlyAddedSong = await AuthService()
                            .createSong(
                          title.text,
                          performers.text,
                          int.parse(year),
                          genre.text,
                          place_holder
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
                        else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Could not add the song'),
                                content: Text('${newlyAddedSong['detail']}',),
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
                      }



                    }
                  } catch (e) {
                    print("Error: $e");
                    // Handle the error as needed
                  }
                },
                child: Text('Add Song'),
              ),
            ),
            SizedBox(height: 15),
            Flexible(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: BeveledRectangleBorder(),
                ),
                onPressed: () => pickAndReadFile(context),
                child: Text('Add From A File'),
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
                onPressed: () async { }, //

                child: Text('Add From Other Apps'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

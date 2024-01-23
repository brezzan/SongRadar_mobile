import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:songradar/api.dart';
import 'dart:core';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:songradar/variables.dart';
import 'dart:io';

class addNewSong extends StatefulWidget {
  final int userid;
  final String username;
  const addNewSong({required this.userid, required this.username, Key? key})
      : super(key: key);

  @override
  State<addNewSong> createState() => _addNewSongState();
}

class _addNewSongState extends State<addNewSong> {
  late int userid;
  late String username;

  TextEditingController title = TextEditingController();
  TextEditingController performers = TextEditingController();
  String year = '';
  String month = '';
  String day = '';

  TextEditingController album = TextEditingController();
  int songs_count = 0;
  int albums_count = 0;

  Future<void> readAlbumsFromMySQL() async {
    final response = await http.get(Uri.parse("http://"+connection+"/songradar_sql/get_albums.php"));

    if (response.statusCode == 200) {
      final List<dynamic> albumDataList = jsonDecode(response.body);

      for (final albumData in albumDataList) {
        if (albumData is Map<String, dynamic>) {

          await addAlbumFromFile(albumData);  // from file fonsksiyonu kullanabilmek icin
        }
      }
    } else {
      print('Failed to load albums from MySQL. Status code: ${response.statusCode}');
    }
  }

  Future<void> readSongsFromMySQL() async {
    final response = await http.get(Uri.parse("http://"+connection+"/songradar_sql/get_songs.php"));
    if (response.statusCode == 200) {
      final List<dynamic> songDataList = jsonDecode(response.body);

      for (final songData in songDataList) {
        if (songData is Map<String, dynamic>) {
          print( songData);
          print( 'inside the loop ');

          if ((songData['album_id']) == '') {
            songData['album_id'] = 'not_existing_album_id';

          }
          await addSongFromFile(songData);
        }
        else {
          print('Wrong data structure: ${response.statusCode}');
        }
      }
    } else {
      print('Failed to load songs from MySQL. Status code: ${response.statusCode}');
    }
  }

  Future<void> readFromExternal(BuildContext context) async {
    try {
      //await readAlbumsFromMySQL();

      await readSongsFromMySQL();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(
              '$albums_count albums and $songs_count songs have been added successfully ',
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
      print('Error: $e');
    }
  }

  Future<void> addAlbumFromFile(Map<String, dynamic> albumData) async {
    String albumTitle = albumData['name'];
    int albumYear = albumData['year'];
    int albumMonth = albumData['month'];
    int albumDay = albumData['day'];
    String albumPerformers = albumData['artists'] ;

    await AuthService().createAlbumUserInput(albumTitle, albumPerformers, albumYear, albumMonth, albumDay);
    albums_count = albums_count +1;

  }

  Future<void> addSongFromFile(Map<String, dynamic> songData ) async {


    print( songData['album_id']);
    print('-----');
    String songTitle = songData['name'];

    int songYear = songData['year'];
    int songMonth = songData['month'];
    int songDay = songData['day'];
    String songPerformers = songData['artists'];

    print("ı am here now $songData['album_id']");
    Map<String, dynamic> albumInfo = await AuthService().getAlbumById(songData['album_id']);
    print("ı am here now $songData['album_id']");

    if(songData['album_id'] == 'not_existing_album_id' || albumInfo.containsKey('detail')){  // there is no album with such id so create an album
      print('need to create album frist');
      Map<String, dynamic> createdAlbumInfo =  await AuthService().createAlbumUserInput(songTitle, songPerformers, songYear, songMonth, songDay);
      albums_count = albums_count +1;
      print('create song');
      await AuthService().createSongUserInput(songTitle, createdAlbumInfo['id'], songPerformers, songYear, songMonth,songDay );
      songs_count = songs_count +1;
    }

    else{
      print('create song');
      await AuthService().createSongUserInput(songTitle, songData['album_id'], songPerformers, songYear, songMonth,songDay );
      songs_count = songs_count +1;
    }


  }

  Future<void> pickAndReadFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      if (Platform.isIOS || Platform.isAndroid) {
        File pickedFile = File(file.path!);

        try {

          List<dynamic> jsonData =await jsonDecode(await pickedFile.readAsStringSync());
          print(jsonData);

          await Future.forEach(jsonData, (element) async {
            print(element);

            if (element is Map<String, dynamic>) {
              if (element.containsKey('album_id')) {
                // It's a song
                await addSongFromFile(element);
                print("added $element - song");

              } else {
                // It's an album
                await addAlbumFromFile(element);
                print("added $element - album");
              }
            } else {
              print('Invalid data structure: $element');
            }

          });

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(
                  '$albums_count albums and $songs_count songs have been added successfully ',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      songs_count = 0;
                      albums_count = 0;
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
        backgroundColor: Colors.grey,
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
                    arguments: {'userid': userid, 'username': username});
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Flexible(
              child: Row(children: [
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: BeveledRectangleBorder()),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/addNewSong',
                            arguments: {
                              'userid': userid,
                              'username': username
                            });
                      },
                      child: Text('Add Song')),
                ),
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: BeveledRectangleBorder()),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/addNewAlbum',
                            arguments: {
                              'userid': userid,
                              'username': username
                            });
                      },
                      child: Text('Add Album')),
                ),
              ]),
            ),
            SizedBox(height: 15),
            Flexible(
              child: TextField(
                controller: title,
                decoration: InputDecoration(
                  icon: Icon(Icons.music_note),
                  hintText: 'Title of Song',
                ),
              ),
            ),
            SizedBox(height: 15),
            Flexible(
              child: TextField(
                controller: album,
                decoration: InputDecoration(
                  icon: Icon(Icons.album_rounded),
                  hintText: 'Album',
                ),
              ),
            ),
            SizedBox(height: 15),
            Flexible(
              child: TextField(
                controller: performers,
                decoration: InputDecoration(
                  icon: Icon(Icons.people_alt_rounded),
                  hintText: 'Performers',
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                child: TextFormField(
                  // Set the controller
                  onChanged: (value) {
                    // Update the new_time_for_brew only when the user modifies the text
                    if (value.isNotEmpty) {
                      day = value;
                    }
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  keyboardType: TextInputType.number, // Show numeric keyboard
                  decoration: const InputDecoration(
                    icon: Icon(Icons.calendar_month_rounded),
                    hintText: 'Day',
                  ),
                ),
              ),
                SizedBox(width :10),
                Flexible(
                  child: TextFormField(
                    // Set the controller
                    onChanged: (value) {
                      // Update the new_time_for_brew only when the user modifies the text
                      if (value.isNotEmpty) {
                        month = value;
                      }
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    keyboardType: TextInputType.number, // Show numeric keyboard
                    decoration: const InputDecoration(
                      hintText: 'Month',
                    ),
                  ),
                ),
                SizedBox(width :10),
                Flexible(
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

                      hintText: 'Year',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 45),
            Flexible(
              child: ElevatedButton(
                child: Text('Add Song'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: BeveledRectangleBorder(),
                ),
                onPressed: () async {
                    String artists = performers.text;

                    if(artists.contains(',')){
                    artists = artists.replaceAll(",", "','");
                    }

                    artists = "['"+ artists +"']";

                    if (album.text.isNotEmpty) {

                        final Map<String, dynamic> newlyAddedAlbum =await AuthService().createAlbumUserInput(album.text, artists, int.parse(year), int.parse(month), int.parse(day));
                        print(newlyAddedAlbum['id']);
                        final Map<String, dynamic> newlyAddedSong = await AuthService().createSongUserInput(title.text, newlyAddedAlbum['id'], artists, int.parse(year), int.parse(month), int.parse(day));

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
                                      Navigator.pushReplacementNamed(context, '/mainAppPage',
                                          arguments: {'userid': userid,'username':username});
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
                                content: Text(
                                  '${newlyAddedSong['detail']}',
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

                      }
                    else {
                      final Map<String, dynamic> newlyAddedAlbum = await AuthService().createAlbumUserInput(title.text, artists, int.parse(year), int.parse(month), int.parse(day));
                      final Map<String, dynamic> newlyAddedSong = await AuthService().createSongUserInput(title.text, newlyAddedAlbum['id'], artists, int.parse(year), int.parse(month), int.parse(day));

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
                                        Navigator.pushReplacementNamed(context, '/mainAppPage',
                                            arguments: {'userid': userid,'username':username});
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
                                  content: Text(
                                    '${newlyAddedSong['detail']}',
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

                        }
                      }
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
                onPressed: () async => pickAndReadFile(context),
                //onPressed: () async { }, //
                child: Text('Add From A File'),
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
                onPressed: () async => readFromExternal(context),
                child: Text('Add From Another Database'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

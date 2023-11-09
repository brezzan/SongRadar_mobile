import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:songradar/api.dart';
import 'dart:core';
import 'dart:convert';
import 'package:songradar/signup.dart';
import 'package:songradar/mainAppPage.dart';

class addNewAlbum extends StatefulWidget {
  final String username;
  const addNewAlbum({required this.username, Key? key}) : super(key: key);

  @override
  State<addNewAlbum> createState() => _addNewAlbumState();
}

class _addNewAlbumState extends State<addNewAlbum> {
  late String username;

  TextEditingController performers = TextEditingController();
  String year = '0';
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
            Text('Add a New Album'),
            SizedBox(
              width: 170,
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
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: BeveledRectangleBorder()
                      ),

                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/addNewSong',
                            arguments: {'username': username});
                      },
                      child: Text('Add Song')),
                ),
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: BeveledRectangleBorder()
                      ),
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
                    shape: BeveledRectangleBorder()
                ),
                onPressed: () async {  // add a new album

                    final Map<String, dynamic> newlyAddedAlbum= await AuthService().createAlbum(album.text, performers.text,int.parse(year), genre.text) ;
                    if (!newlyAddedAlbum.containsKey('error')) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                              'Album added to system',
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
                            title: Text('Could not add the album'),
                            content: Text( '${newlyAddedAlbum['detail']}', ),
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
                },
                child: Text('Add Album'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

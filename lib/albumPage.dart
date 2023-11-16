import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'dart:convert';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';

/*

album info and all song info
delete_album function will be here
Navıgate to mainAppPage after confirming a alertdialog like 'are you sure about deleting this album ?'


can be implemented

 */

class albumPage extends StatefulWidget {
  final int albumId, userid; // Corrected variable name to userId
  final String username;
  const albumPage(
      {required this.albumId,
      required this.userid,
      required this.username,
      Key? key})
      : super(key: key);

  @override
  State<albumPage> createState() => _albumPageState();
}

class _albumPageState extends State<albumPage> {
  late int userid; // Corrected variable name to userId
  late int albumId;
  late String username;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userid = int.parse('${arguments?['userid']}');
    albumId = int.parse('${arguments?['albumId']}');
    username = '${arguments?['username']}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/mainAppPage',
                      arguments: {'userid': userid, 'username': username});
                },
              ),
            ),
            Flexible(
              child: SizedBox(
                width: 5,
              ),
            ),
            Text('Album Page'),
            Flexible(
              child: SizedBox(
                width: 100,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Flexible(
                child: Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: BeveledRectangleBorder()),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Delete'),
                                content: Text(
                                    'Are you sure you want to delete this album?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                      child: Text('Delete'),
                                      onPressed: () async {
                                        final Map<String, dynamic>deletedAlbum = await AuthService().deleteAlbum(albumId);
                                        print(deletedAlbum);
                                        if (!deletedAlbum.containsKey('error')) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Success'),
                                                content: Text('Album deleted'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text('OK'),
                                                    onPressed: () {
                                                      Navigator.pushReplacementNamed(context, '/mainAppPage',
                                                              arguments: {'userid': userid, 'username': username
                                                          });
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          // Handle deletion error here
                                          Navigator.of(context).pop();
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Error'),
                                                content: Text(
                                                    'Album could not be deleted'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text('OK'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      }),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Delete Album'))),
                Expanded(child: Text('Album Id :$albumId')),
                Expanded(child: Text('Album name: ')),
              ],
            ))
          ],
        ),
      ),
    );
  }
}

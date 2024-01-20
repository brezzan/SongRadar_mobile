import 'package:flutter/material.dart';
import 'dart:core';
import 'package:songradar/variables.dart';
import 'package:songradar/api.dart';

class personalPage extends StatefulWidget {
  final int userid;
  final String username;
  const personalPage({required this.userid, required this.username, Key? key})
      : super(key: key);

  @override
  State<personalPage> createState() => _personalPageState();
}

class _personalPageState extends State<personalPage> {
  late int userid;
  late String username;
  List<dynamic> playlists = [];

  Future<List<dynamic>> fetchPlaylists() async {
    return await AuthService().getUserPlaylists();
  }

  @override
  void initState() {
    fetchPlaylists();
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
                            Navigator.pushReplacementNamed(context, '/login', arguments: {});
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.pushReplacementNamed(context, '/starredSongsPage',
                        arguments: {'userid': userid, 'username': username});
                  },
                  child: Column(
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
                            color: Colors.black12,
                          ),
                          child: Center(
                            child: Icon(Icons.music_note,size: 60,),
                          ),
                        ),
                      ),
                      Text('Favorite Songs',style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: (){},
                  child: Column(
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
                            color: Colors.black12,
                          ),
                          child: Center(
                            child: Icon(Icons.album,size: 60,),
                          ),
                        ),
                      ),
                      Text('Favorite Albums',style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: (){},
                  child: Column(
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
                            color: Colors.black12,
                          ),
                          child: Center(
                            child: Icon(Icons.person,size: 60,),
                          ),
                        ),
                      ),
                      Text('Favorite Artists',style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
            GestureDetector(
              onTap:(){
                Navigator.pushReplacementNamed(context, '/createplaylist',
                  arguments: {'userid': userid, 'username': username});
                },  // add a playlist
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.black12,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add,size:35),
                            Text(' Create New Playlist',style: TextStyle(fontSize: 25),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            FutureBuilder(
              future: fetchPlaylists(),
              builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<dynamic> playlists = snapshot.data ?? [];

                  return Container(
                    height: 1000, // You can adjust the height as needed
                    child: ListView.builder(
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        IconData iconData = Icons.music_note;
                        var playlist = playlists[index];

                        return ListTile(
                          onTap: (){
                            global_playlist = playlist['id'];
                            global_playlist_name = playlist['name'];
                            Navigator.pushReplacementNamed(context, '/playlistPage',
                                arguments: {'userid': userid, 'username': username,'playlistId':global_playlist});
                          },
                          leading: Icon(iconData),
                          tileColor: Colors.grey[50],
                          title: Text(playlist['name']),
                          trailing: IconButton(
                            onPressed: () async {
                              await AuthService().deletePlaylist(playlist['id']);
                              setState(() {
                                playlists.removeAt(index);
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

          ],
        ),
      ),
    );
  }
}


/*
 trailing: IconButton(
                            onPressed: () async {
                              await AuthService().deletePlaylist(playlist['id']);
                              setState(() {
                                playlists.removeAt(index);
                              });
                            },
                            icon: Icon(Icons.delete),
                          ),*/
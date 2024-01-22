import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:songradar/api.dart';
import 'dart:core';

class manageFriends extends StatefulWidget {
  final int userid;
  final String username;
  const manageFriends({required this.userid, required this.username, Key? key})
      : super(key: key);

  @override
  State<manageFriends> createState() => _manageFriendsState();
}

class _manageFriendsState extends State<manageFriends> {
  late int userid;
  late String username;

  String friend_id = '';
  TextEditingController friend = TextEditingController();



  Future<List<Map<String, dynamic>>> getRequets() async {
    return await AuthService().getFriendRequest();
  }

  Future<List<Map<String, dynamic>>> getFriends() async {
    return await AuthService().getFriends();
  }

  @override
  void initState() {

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
                    arguments: {
                      'userid': userid,
                      'username': username
                    });
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text('Friends Activity'),
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: TextFormField(
                    // Set the controller
                    onChanged: (value) {
                      // Update the new_time_for_brew only when the user modifies the text
                      if (value.isNotEmpty) {
                        friend_id = value;
                      }
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    keyboardType: TextInputType.number, // Show numeric keyboard
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person_add_rounded),
                      hintText: 'Friend id',
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Flexible(
                  child: ElevatedButton(
                      child: Text('Send Request'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: BeveledRectangleBorder(),
                      ),
                      onPressed: () async {
                        if (friend_id.isNotEmpty) {
                          int friend = int.parse(friend_id);
                          Map<String, dynamic> sendRequest =
                              await AuthService().sendFriendRequest(friend);
                          if (!sendRequest.containsKey('error')) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Text(
                                    'Friendship Request Sent',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(
                                            context, '/personalPage',
                                            arguments: {
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
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Could not send request'),
                                  content: Text(
                                    '${sendRequest['error']}',
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
                      }),
                ),
              ],
            ),
            SizedBox(height: 45),
            Flexible(
              child: Divider(
                height: 5,
                thickness: 1,
                color: Colors.grey,
              ),
            ),

            SingleChildScrollView(
              child: FutureBuilder(
                future: getRequets(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<Map<String, dynamic>> requests = snapshot.data ?? [];
                    return Container(
                      height: 100, // You can adjust the height as needed
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          IconData iconData = Icons.person;
                          var request = requests[index];
                          if(requests.length >0)
                            if (request['status'] == 'pending')
                              return ListTile(
                                leading: Icon(iconData),
                                title: Text(request['requester_name']),
                                subtitle: Text(request['status']),
                                trailing: IconButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Text(
                                            'Accept/Reject Friendship ?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                Map<String, dynamic> response =
                                                    await AuthService()
                                                        .acceptRequest(
                                                            request['id']);
                                                if (!response
                                                    .containsKey('error')) {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        content: Text(
                                                          'Friendship Request Accepted',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pushReplacementNamed(
                                                                  context, '/personalPage',
                                                                  arguments: {
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
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Could not accept request'),
                                                        content: Text(
                                                          '${response['error']}',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text('OK'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              child: Text('Accept'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Map<String, dynamic> response =
                                                    await AuthService()
                                                        .rejectRequest(
                                                            request['id']);
                                                if (!response
                                                    .containsKey('error')) {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        content: Text(
                                                          'Friendship Request Rejected',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pushReplacementNamed(
                                                                  context, '/personalPage',
                                                                  arguments: {
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
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Could not reject request'),
                                                        content: Text(
                                                          '${response['error']}',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text('OK'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              child: Text('Reject'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.more_horiz),
                                ),
                              );
                          else{
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('You have no friendship requests.',style: TextStyle(fontSize: 20),),
                              ],
                            );
                            }
                        },
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 15),
            Flexible(
              child: Divider(
                height: 5,
                thickness: 1,
                color: Colors.grey,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Current Friends: ',style: TextStyle(fontSize: 20),),
              ],
            ),
            SingleChildScrollView(
              child: FutureBuilder(
                future: getFriends(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<Map<String, dynamic>> friends = snapshot.data ?? [];
                    return Container(
                      height:100, // You can adjust the height as needed
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          IconData iconData = Icons.person;
                          var request = friends[index];
                          if(friends.length >0)
                              return ListTile(
                                leading: Icon(iconData),
                                title: Text(request['username']),
                              );
                            else{
                              return Text('You have no friends :(');
                            }
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
trailing: Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Text(
                                            'Accept/Reject Friendship ?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () async{
                                                Map<String, dynamic> response = await AuthService().acceptRequest(request['id']);
                                                if (!response.containsKey('error')) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        content: Text(
                                                          'Friendship Request Accepted',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator
                                                                  .pushReplacementNamed(
                                                                  context,
                                                                  '/personalPage',
                                                                  arguments: {
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
                                                }
                                                else {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Could not accept request'),
                                                        content: Text(
                                                          '${response['error']}',
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
                                              },
                                              child: Text('Accept'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Map<String, dynamic> response =
                                                await AuthService()
                                                    .rejectRequest(request['id']);
                                                if (!response.containsKey('error')) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        content: Text(
                                                          'Friendship Request Rejected',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator
                                                                  .pushReplacementNamed(
                                                                  context,
                                                                  '/personalPage',
                                                                  arguments: {
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
                                                }
                                                else {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Could not reject request'),
                                                        content: Text(
                                                          '${response['error']}',
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
                                              },
                                              child: Text('Reject'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                  },
                                  icon: Icon(Icons.more_horiz),
                                ),
                              ],
                            ),
 */

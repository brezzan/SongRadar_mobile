import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';
import 'package:songradar/sqlHelper.dart';
import 'package:songradar/mainAppPage.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({Key? key}) : super(key: key);

  @override

  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _passwordVisible = false;


  @override
  void initState() {
      SqlHelper.dbPath();
  }

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Text('Sound Radar Login'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            TextField(
              controller: username,
              decoration: InputDecoration(
                icon: Icon(Icons.mail_outline),
                hintText: 'Username',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: password,
              obscureText: !_passwordVisible, // Obscure text if _passwordVisible is false
              decoration: InputDecoration(
                icon: Icon(Icons.vpn_key),
                hintText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final List<Map<String, dynamic>> user_info = await SqlHelper.searchUser(username.text, password.text);
                print(user_info);

                if (user_info.isNotEmpty) {
                  // successful login to main page
                  Navigator.pushReplacementNamed(context,'/mainAppPage', arguments:{'username': username.text});

                } else {
                  // Display an error message if the login fails
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Login Failed'),
                        content: Text('Invalid username or password. Please try again.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                Navigator.pushReplacementNamed(context, '/signup', arguments: {});
              },
              child: Text('If you do not have an account, click here to sign up'),
            ),
          ],
        ),
      ),
    );
  }
}

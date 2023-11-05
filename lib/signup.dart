import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:songradar/api.dart';

import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController mail = TextEditingController();
  bool _passwordVisible = false;




  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        title: Text('Sound Radar Sign Up'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            TextField(
              controller: username,
              decoration: InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'Username',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: mail,
              decoration: InputDecoration(
                icon: Icon(Icons.mail_outline),
                hintText: 'Mail',
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
                if (username.text.isNotEmpty && password.text.isNotEmpty) {
                  final Map<String, dynamic> loginResult =
                  await authService.loginUser(username.text, password.text);

                  if (!loginResult.containsKey('error')) {
                    // Successful login
                    print('Login successful! Access Token: ${loginResult['access_token']}');

                    // TODO: Navigate or perform actions after successful login
                  } else {
                    // Display an error message if the login fails
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Login Failed'),
                          content: Text(
                            'Invalid username or password. Please try again.',
                          ),
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
                }
              },
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                Navigator.pushReplacementNamed(context, '/login', arguments: {});
              },
              child: Text('If you are already signed up, click here to login'),
            ),
          ],
        ),
      ),
    );
  }
}

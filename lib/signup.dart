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
            Flexible (
              child: TextField(
                controller: username,
                decoration: InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Username',
                ),
              ),
            ),
            SizedBox(height: 20),
            Flexible (
              child: TextField(
                controller: mail,
                decoration: InputDecoration(
                  icon: Icon(Icons.mail_outline),
                  hintText: 'Mail',
                ),
              ),
            ),
            SizedBox(height: 20),
            Flexible (
              child: TextField(
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
            ),
            SizedBox(height: 20),
            Flexible (
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  if (username.text.isNotEmpty && mail.text.isNotEmpty && password.text.isNotEmpty) {
                    final Map<String, dynamic> signUpResult = await authService.signUpUser(username.text,mail.text, password.text);

                    if (!signUpResult.containsKey('error')) {
                      // Successful login
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Successful Sign Up '),
                            content: Text(
                              'You can login now',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/login', arguments: {});
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Display an error message if the login fails
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Sign Up Failed'),
                            content: Text('${signUpResult['detail']}'),
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
                child: Text('Sign Up'),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),

            Flexible (
              child: ElevatedButton(
                onPressed: () async {

                  Navigator.pushReplacementNamed(context, '/login', arguments: {});

                },
                child: Text('If you are already signed up, click here to login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

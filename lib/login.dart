import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:songradar/api.dart';
import 'dart:core';
import 'dart:convert';
import 'package:songradar/signup.dart';
import 'package:songradar/mainAppPage.dart';


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
  Widget build(BuildContext context) {
    final authService = AuthService();

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
                controller: password,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  icon: Icon(Icons.vpn_key),
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
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
                  if (username.text.isNotEmpty && password.text.isNotEmpty) {
                    final Map<String, dynamic> loginResult = await authService.loginUser(username.text, password.text);

                    if (!loginResult.containsKey('error')) {

                      final String accessToken = loginResult['access_token'];
                      final Map<String, dynamic> userResult = await authService.getUser(accessToken);
                      print(userResult);
                      if(!userResult.containsKey('error')){

                        Navigator.pushReplacementNamed(context, '/mainAppPage', arguments: {'username': userResult['username']});
                        // successful loginnn

                      } else {
                        // Display an error message if the login fails
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Login Failed'),
                              content: Text('${loginResult['error']}'),
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
                    } else {
                      // Display an error message if the login fails
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Login Failed'),
                            content: Text('${loginResult['error']}'),
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
                }, child: Text('Login'),

              ),
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            SizedBox(height: 20),
            Flexible (
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child: Text('If you do not have an account, click here to sign up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';
import 'package:songradar/login.dart';
import 'package:songradar/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);


  @override


  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int _counter = 0;
  TextEditingController user = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _passwordVisible = false;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<void> login(String mail, String password) async {

    // var url = Uri.parse(connection+"login.php");
    var body = {
      "user_mail": mail,
      "user_password": password,
    };
    /*
    try {

      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        try {
          var datauser = response.body;
          if (datauser is String && datauser.isNotEmpty) {
            mail = jsonDecode(datauser)[0]['mail']; // Assign the mail value
            String password1 = jsonDecode(datauser)[0]['password'];
            Navigator.pushReplacementNamed(context, '/logged',
                arguments: {'mail': mail, "password": password1});
          }
        } catch (e) {
          debugPrint('Failed to parse response as JSON: ${response.body}');
        }
      } else {
        throw Exception('Failed to login. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('$e');
    }
*/

  }
  @override
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
              controller: user,
              decoration: InputDecoration(
                icon: Icon(Icons.mail_outline),
                hintText: 'User mail',
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

                //await login(user.text, password.text);
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

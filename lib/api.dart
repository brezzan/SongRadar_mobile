import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl =
      'http://10.0.2.2:8000'; // Replace with your actual API base URL

  Future<Map<String, dynamic>> loginUser(String username,
      String password) async {
    final String loginUrl = '$baseUrl/auth/sign_in';

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'accept': 'application/json',
    };

    final Map<String, String> body = {
      'username': username,
      'password': password,
      'scope': '',
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(loginUrl),
        headers: headers,
        body: body,
      );

      print('Response Body: ${response.body}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful login
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Extract the access token and token type
        final String accessToken = responseData['access_token'];
        final String tokenType = responseData['token_type'];

        return {'access_token': accessToken, 'token_type': tokenType};

      } else {
        // Handle login error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'error': errorData['detail']};
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> getUser(String accessToken) async {
    final String meUrl = '$baseUrl/auth/me';

    final Map<String, String> headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final http.Response response = await http.get(
        Uri.parse(meUrl),
        headers: headers,
      );

      print('User Response Body: ${response.body}');
      print('User Response Status Code: ${response.statusCode}');
      print('User Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        return userData;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'error': errorData['detail']};
      }
    } catch (error) {
      print('Error: $error');
      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> getUserbyID(int userId) async {    // works but depends on userid argument that comes with widget build so it takes time and requires future build
    final String getUserUrl = '$baseUrl/debug/users/$userId';

    final Map<String, String> headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      final http.Response response = await http.get(
        Uri.parse(getUserUrl),
        headers: headers,
      );

      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Successful user retrieval
        final Map<String, dynamic> userData = jsonDecode(response.body);
        print(userData);
        return userData;
      } else {
        // Handle error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'error': errorData['detail']};
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> signUpUser(String username, String email,
      String password) async {
    final String signUpUrl = '$baseUrl/auth/sign_up';

    final Map<String, String> headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final Map<String, String> body = {
      'username': username,
      'email': email,
      'password': password,
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(signUpUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        // Successful signup
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        // Handle signup error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'error': response.body};
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');

      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<List<Map<String, dynamic>>> getAlbums() async {   // get albums and the songs they contain
    final String url = '$baseUrl/debug/albums?skip=0&limit=100';
    final response = await http.get(Uri.parse(url));
    try {

      final http.Response response = await http.get(Uri.parse(url),);

      if (response.statusCode == 200) {
        List<dynamic> albumsJson = jsonDecode(response.body);
        List<Map<String, dynamic>> albums = [];

        for (var albumJson in albumsJson) {
          albums.add(Map<String, dynamic>.from(albumJson));

        }
        return albums;  //return albums
      } else {
        return [];
      }
    }
    catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [{'error': 'An unexpected error occurred.'}];
    }
  }

  Future<Map<String, dynamic>> createAlbum(String album, String performers, int year, String genre) async {
    final String url = '$baseUrl/debug/album';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'accept': 'application/json',
    };

    final Map<String, dynamic> body = {
      'title': album,
      'year': year,
      'genre': genre,
      'performers': performers
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Successful signup
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        // Handle signup error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'error': response.body};
      }
    }
    catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> deleteAlbum(int album_id) async {
    final String url = '$baseUrl/debug/album?album_id=$album_id';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'accept': 'application/json',
    };

    final Map<String, dynamic> body = {
      'album_id': album_id,
    };

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Successful delete
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        // Handle delete error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'error': errorData['detail']};
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<List<Map<String, dynamic>>> getSongs() async {
    final String url = '$baseUrl/debug/songs?skip=0&limit=100';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'accept': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> songsJson = jsonDecode(response.body);
        List<Map<String, dynamic>> songs = [];

        for (var albumJson in songsJson) {
          songs.add(Map<String, dynamic>.from(albumJson));

        }
        return songs;  //return albums
      } else {
        return [];
      }
    }
    catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [{'error': 'An unexpected error occurred.'}];
    }
  }

  Future<Map<String, dynamic>> createSong(String title, String performers, int year, String genre,int album_id)async {
    final String url = '$baseUrl/debug/songs';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> body = {
      'title': title,
      'year': year,
      'genre': genre,
      'performers': performers,
      'album_id':album_id
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Successful signup
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData);
        return responseData;
      } else {
        // Handle signup error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'error': response.body};
      }

    }
    catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return {'error': 'An unexpected error occurred.'};
    }
  }


}
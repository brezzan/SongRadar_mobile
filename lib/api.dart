import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

String accessToken = '';
// 'Authorization': 'Bearer $accessToken',
class AuthService {

  final String baseUrl = 'http://10.0.2.2:8000'; //


  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final String loginUrl = '$baseUrl/auth/sign_in';

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'accept': 'application/json',
    };

    final Map<String, String> body = {
      'username': username,
      'password': password,
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(loginUrl),
        headers: headers,
        body: body,
      );

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
  } // auth

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

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        return userData;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'error': errorData['detail']};
      }
    } catch (error) {
      return {'error': 'An unexpected error occurred.'};
    }
  } // auth

  Future<Map<String, dynamic>> getUserbyID(int userId) async {
    // works but depends on userid argument that comes with widget build so it takes time and requires future build
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
  }  //debug

  Future<Map<String, dynamic>> signUpUser(String username, String email, String password) async {
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
  } // auth

  // will be deleted
  Future<List<Map<String, dynamic>>> getAlbums() async {
    // get albums and the songs they contain
    final String url = '$baseUrl/debug/albums?skip=0&limit=10';
    final response = await http.get(Uri.parse(url));
    try {
      final http.Response response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        List<dynamic> albumsJson = jsonDecode(response.body);
        List<Map<String, dynamic>> albums = [];

        var i = 0;
        for (var albumJson in albumsJson) {
          if (i < 10) {
            albums.add(Map<String, dynamic>.from(albumJson));
            i = i + 1;
          }
        }
        return albums; //return albums
      } else {
        return [];
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [
        {'error': 'An unexpected error occurred.'}
      ];
    }
  }  // no longer should be used - addnewSong addnewalbum pages must be recalled with new functions


  // do not use - debug
  Future<Map<String, dynamic>> createAlbum(String album, String performers, int year, String genre) async {
    final String url = '$baseUrl/debug/album';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'accept': 'application/json',
    };

    final Map<String, dynamic> body = {
        "id": "string",
        "name": "string",
        "artists": "string",
        "artist_ids": "string",
        "number_of_tracks": 0,
        "explicit": true,
        "danceability": 0,
        "energy": 0,
        "key": 0,
        "loudness": 0,
        "mode": 0,
        "speechiness": 0,
        "acousticness": 0,
        "instrumentalness": 0,
        "liveness": 0,
        "valence": 0,
        "tempo": 0,
        "duration_ms": 0,
        "time_signature": 0,
        "year": 0,
        "month": 0,
        "day": 0,
        "owner_id": 0
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
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return {'error': 'An unexpected error occurred.'};
    }
  }  //debug
  // do not use - debug
  Future<Map<String, dynamic>> deleteAlbum_old(int album_id) async {
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
  // do not use - debug
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
        return songs; //return albums
      } else {
        return [];
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [
        {'error': 'An unexpected error occurred.'}
      ];
    }
  }
  // do not use - debug - old
  Future<Map<String, dynamic>> createSong(String title, String performers, int year, String genre, int album_id) async {
    final String url = '$baseUrl/debug/songs';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> body = {
      'title': title,
      'year': year,
      'genre': genre,
      'performers': performers,
      'album_id': album_id
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
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return {'error': 'An unexpected error occurred.'};
    }
  }


  ////////////////////////////////////////////////////  SONGS  /////////////////////////////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> deleteSong(String id) async {
    final String url = '$baseUrl/songs/$id';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return [
          {'succces': 'Succesfully deleted song with id $id'}
        ];
      }
      else {
        return [
          {'error': '${response.statusCode}'}
        ];
      }
    }catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [
        {'error': 'An unexpected error occurred.'}
      ];
    }
  }

  Future<Map<String, dynamic>> createSongUserInput(String name, String album_id, String artists, int year, int month, int day) async {
    final String url = '$baseUrl/songs/';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',

    };
    final Map<String, dynamic> body = {
        "name": name ,
        "album_id": album_id,
        "artists": artists,
        "year": year,
        "month": month,
        "day": day
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
        return {'error': response.body};
      }
    } catch (error) {
      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<List<Map<String, dynamic>>> getSongsFromCsv({int skip = 0, int limit = 20}) async {  //works
    final String url = '$baseUrl/songs/?skip=$skip&limit=$limit';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List< dynamic> songsJson = jsonDecode(response.body);
        List<Map<String, dynamic>> songs = [];

        for (var songJson in songsJson) {
          // Add each song directly without checking the index
          songs.add(Map<String, dynamic>.from(songJson));
        }

        return songs;
      } else {
        // Handle non-200 status codes
        print('Error-song: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error-song: $error');
      return [{'error-song': 'An unexpected error occurred.'}];
    }
  }

  Future<List<dynamic>> readUserSongs({int skip = 0, int limit = 100}) async {
    final String url = '$baseUrl/songs/user?skip=$skip&limit=$limit';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {

        List<dynamic> songs = jsonDecode(response.body);
        print( "user songs : $songs");
        return songs;

      } else {
        // Handle non-200 status codes
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [{'error': 'An unexpected error occurred.'}];
    }
  }

  Future<List<dynamic>> readRecentSongs({int skip = 0, int limit = 10}) async {
    final String url = '$baseUrl/songs/recent?skip=$skip&limit=$limit';

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

        List<dynamic>  songs = jsonDecode(response.body);
        return songs;

      } else {
        // Handle non-200 status codes
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [{'error': 'An unexpected error occurred.'}];
    }
  }

  Future<List<dynamic>> getSongByName(String songName) async { //works
    final String url =
        '$baseUrl/songs/search_name?name=$songName&skip=0&limit=10';
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
        final List<dynamic> responseData = jsonDecode(response.body);
        print(responseData);
        return responseData;
      } else {
        // Handle signup error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return [{'error': errorData}];
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [{'error': 'An unexpected error occurred.'}];
    }
  }

  Future<List<dynamic>> getSongByArtist(String artistName,{int skip = 0, int limit = 10}) async {
    final String url = '$baseUrl/songs/search_artist?artist=$artistName&skip=$skip&limit=$limit';
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
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return [{'error': response.body}];
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [{'error': 'An unexpected error occurred.'}];
    }
  }

  Future<int> getSongCount() async {  // works
    final String url = '$baseUrl/songs/count';
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
        final int responseData = jsonDecode(response.body);
        print('number of songs in the csv is $responseData');
        return responseData;
      } else {
        // Handle signup error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return 0;
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return -1;
    }
  }

  Future<Map<String, dynamic>> getSongById(String id) async {
    final String url = '$baseUrl/songs/find/$id';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        return responseData;
      } else {
        // Handle error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'error': response.body};
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<String> getSongCoverById(String id) async {
    final String url = '$baseUrl/songs/cover/$id';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final String responseData = jsonDecode(response.body);

        return responseData;
      } else {
        return 'An unexpected error occurred.';
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return '$error An unexpected error occurred.';
    }
  }



/////////////////////////////////////////////////////  ALBUMS  /////////////////////////////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> deleteAlbum(String id) async {
    final String url = '$baseUrl/albums/$id';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return [
          {'succces': 'Succesfully deleted album with id $id'}
        ];
      }
      else {
        return [
          {'error': '${response.statusCode}'}
        ];
      }
    }catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [
        {'error': 'An unexpected error occurred.'}
      ];
    }
  }

  Future<Map<String, dynamic>> createAlbumUserInput(String name, String artists, int year, int month, int day) async {
    final String url = '$baseUrl/albums/';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final Map<String, dynamic> body = {
      "name": name,
      "artists": artists,
      "year": year,
      "month": month,
      "day": day
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {

        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('okay ${response.statusCode}');
        return responseData;
      } else {
        print('not okay 2${response.statusCode}');
        return {'error': response.body};
      }
    } catch (error) {
      print('not okay 3');
      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<List<Map<String, dynamic>>> getAlbumsFromCsv({int skip = 0, int limit = 20}) async {
    final String url = '$baseUrl/albums/?skip=$skip&limit=$limit';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> albumsJson = jsonDecode(response.body);
        List<Map<String, dynamic>> albums = [];

        var i = 0;
        for (var albumJson in albumsJson) {
          if (i < 10) {
            albums.add(Map<String, dynamic>.from(albumJson));
            i = i + 1;
          }
        }
        return albums; //return albums
      } else {
        // Handle signup error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return [
          {'error-album': response.body}
        ];
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error-album: $error');
      return [
        {'error': 'An unexpected error occurred.'}
      ];
    }
  }

  Future<List<dynamic>> readUserAlbums({int skip = 0, int limit = 100}) async {
    final String url = '$baseUrl/albums/user?skip=$skip&limit=$limit';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {

        List<dynamic> albums = jsonDecode(response.body);
        print( "user albums : $albums");
        return albums;

      } else {
        // Handle non-200 status codes
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [{'error': 'An unexpected error occurred.'}];
    }
  }

  Future<List<dynamic>> readRecentAlbums({int skip = 0, int limit = 10}) async {
    final String url = '$baseUrl/albums/recent?skip=$skip&limit=$limit';

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

        List<dynamic> albums = jsonDecode(response.body);
        return albums;

      } else {
        // Handle non-200 status codes
        print('Error: ${response.statusCode}');
        return [{'error': 'An unexpected error occurred.'}];
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [{'error': 'An unexpected error occurred.'}];
    }
  }

  Future<List<dynamic>> getAlbumByName(String albumName) async {  //works
    final String url =
        '$baseUrl/albums/search_name?name=$albumName&skip=0&limit=10';
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
        final List<dynamic> responseData = jsonDecode(response.body);
        print(responseData);
        return responseData;
      } else {
        // Handle signup error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return [{'error': response.body}];
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [{'error': 'An unexpected error occurred.'}];
    }
  }

  Future<List<Map<String, dynamic>>> getAlbumByArtist( String artistName) async {
    final String url =
        '$baseUrl/albums/search_artist?artist=$artistName&skip=0&limit=100';

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
        List<dynamic> albumsJson = jsonDecode(response.body);
        List<Map<String, dynamic>> albums = [];

        var i = 0;
        for (var albumJson in albumsJson) {
          if (i < 10) {
            albums.add(Map<String, dynamic>.from(albumJson));
            i = i + 1;
          }
        }
        return albums;
      } else {
        // Handle signup error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return [{'error': response.body}];
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [{'error': 'An unexpected error occurred.'}];
    }
  }

  Future<int> getAlbumCount() async {  // works
    final String url = '$baseUrl/albums/count';
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
        final int responseData = jsonDecode(response.body);
        print('number of albums in the csv is $responseData');
        return responseData;
      } else {
        return 0;
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return -1;
    }
  }

  Future<Map<String, dynamic>> getAlbumById(String id) async {   // works
    final String url = '$baseUrl/albums/find/$id';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(
            response.body);
        print(responseData);
        return responseData;
      } else {
        // Handle error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'error': response.body};
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<String> getAlbumCoverById(String id) async {
    final String url = '$baseUrl/albums/cover/$id';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final String responseData = jsonDecode(response.body);

        return responseData;
      } else {

        return 'An unexpected error occurred.';
      }
    } catch (error) {

      return '$error An unexpected error occurred.';
    }
  }



/////////////////////////////////////////////////////  PLAYLISTS  /////////////////////////////////////////////////////////////////////////

  Future<Map<String, dynamic>> createPlaylist(String name) async {
    final String url = '$baseUrl/playlists/';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final Map<String, dynamic> body = {
      "name": name
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
        return {'error': response.body};
      }
    } catch (error) {
      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<String > deletePlaylist(int id) async {
    final String url = '$baseUrl/playlists/$id';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return 'succces: Succesfully deleted playlist with id $id';
      }
      else {
        return 'error: ${response.statusCode}';
      }
    }catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return 'An unexpected error occurred.';
    }
  }

  Future<Map<String, dynamic>> renamePlaylist(int id,String name) async {
    final String url = '$baseUrl/playlists/$id?new_name=$name';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final Map<String, dynamic> body = {
      "name": name
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Successful signup
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        return responseData;
      } else {
        return {'error': response.body};
      }
    } catch (error) {
      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> getPlaylistById(int id) async {
    final String url = '$baseUrl/playlists/$id';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;

      } else {
        return {'error': response.body};
      }
    } catch (error) {
      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> putToPlaylist (String songId, int playlistId) async {
    final String url = '$baseUrl/playlists/$playlistId/$songId';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };


    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Successful signup
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        return responseData;
      } else {
        return {'error': response.body};
      }
    } catch (error) {
      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> deleteSongFromPlaylist (String songId, int playlistId) async {
    final String url = '$baseUrl/playlists/$playlistId/$songId';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };


    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Successful signup
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        return responseData;
      } else {
        return {'error': response.body};
      }
    } catch (error) {
      return {'error': 'An unexpected error occurred.'};
    }
  }

  Future<List<dynamic>> getUserPlaylists({int skip = 0, int limit = 100}) async {
    final String url = '$baseUrl/playlists/user?skip=$skip&limit=$limit';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {

        final List<dynamic> responseData = jsonDecode(response.body);
        print('Response Data: $responseData');
        return responseData;

      } else {
        return [{'error': response.statusCode }];
      }
    } catch (error) {
      return [{'error': '$error An unexpected error occurred.'}];
    }
  }


/////////////////////////////////////////////////////  STARRED - ALL NEEDS FIXING  /////////////////////////////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> starASong(String id) async {
    final String url = '$baseUrl/starred/$id';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',

    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {

        final List<Map<String, dynamic>> responseData = jsonDecode(response.body);

        return responseData;
      } else {
        return [{'error': response.body}];
      }
    } catch (error) {
      return [{'error': 'An unexpected error occurred.'}];
    }
  }

  Future<List<Map<String, dynamic>>> UnstarASong(String id) async {
    final String url = '$baseUrl/starred/$id';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {

        final List<Map<String, dynamic>> responseData = jsonDecode(response.body);

        return responseData;
      } else {
        return [{ '${response.statusCode}': response.body}];
      }
    } catch (error) {
      return [{'error': 'An unexpected error occurred.'}];
    }
  }

  Future<List<Map<String, dynamic>>> getStarred() async {
    final String url = '$baseUrl/starred/';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {

        final List<Map<String, dynamic>> responseData = jsonDecode(response.body);

        return responseData;
      } else {
        return [{'error': response.body}];
      }
    } catch (error) {
      return [{'error': 'An unexpected error occurred.'}];
    }
  }



/////////////////////////////////////////////////////  RECOMMEND  /////////////////////////////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> recommend(String songID ,int recommend) async {
    final String url = '$baseUrl/recommend/song/$songID?recommed=$recommend';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {

        final List<Map<String, dynamic>> responseData = List<Map<String, dynamic>>.from(jsonDecode(response.body));

        return responseData;
      } else {
        return [{'error1': response.body}];
      }
    } catch (error) {
      return [{'error2': 'An unexpected error occurred.'}];
    }
  }




}

class Song {
  final String id;
  final String name;
  final String album;
  final String album_id;
  final String artists;
  final String artist_ids;
  final int track_number;
  final int disc_number;
  final bool explicit;
  final double danceability;
  final double energy;
  final int key;
  final double loudness;
  final int mode;
  final double speechiness;
  final double acousticness;
  final double instrumentalness;
  final double liveness;
  final double valence;
  final double tempo;
  final int duration_ms;
  final int time_signature;
  final int year;
  final int month;
  final int day;
  final int owner_id;

  Song({
    required this.id,
    required this.name,
    required this.album,
    required this.album_id,
    required String artists,
    required String artist_ids,
    required this.track_number,
    required this.disc_number,
    required this.explicit,
    required this.danceability,
    required this.energy,
    required this.key,
    required this.loudness,
    required this.mode,
    required this.speechiness,
    required this.acousticness,
    required this.instrumentalness,
    required this.liveness,
    required this.valence,
    required this.tempo,
    required this.duration_ms,
    required this.time_signature,
    required this.year,
    required this.month,
    required this.day,
    required this.owner_id,
  }) : artists = artists.replaceAll("'","" ).replaceAll("[","" ).replaceAll("]","" ),
        artist_ids = artist_ids.replaceAll("'","" ).replaceAll("[","" ).replaceAll("]","" );

  Color getVibeColor_energy() {
    // Adjust the weights based on the importance of each characteristic
    double weightedValue = energy ;
    // Map the weighted value to the hue in HSL color space
    double hue = (1.0 - weightedValue) * 120.0; // Adjust the multiplier for a different hue range

    // Create a vibrant color based on the hue
    Color color = HSLColor.fromAHSL(1.0, hue, 1.0, 0.5).toColor();

    return color;
  }



  Widget getCharacteristicsChart() {
    return Container(
      height: 600, // Set the desired height for the chart
      width: 400,
      child: BarChart(
        BarChartData(

          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: energy,
                  color: Colors.blueAccent[200] ,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: speechiness,
                  color: Colors.greenAccent[200] ,
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: acousticness,
                  color: Colors.orangeAccent[200] ,
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: instrumentalness,
                  color: Colors.blueAccent[400] ,
                ),
              ],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(
                  toY: liveness,
                  color: Colors.greenAccent[400] ,
                ),
              ],
            ),
            BarChartGroupData(
              x: 5,
              barRods: [
                BarChartRodData(
                    toY: valence,
                    color: Colors.orangeAccent[400]
                ),
              ],
            ),
            BarChartGroupData(
              x: 6,
              barRods: [
                BarChartRodData(
                    toY: danceability,
                    color: Colors.blueAccent[600]
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String str = '';
                if (value == 0) {
                  str = 'energy';
                } else if (value == 1) {
                  str = 'speechiness';
                } else if (value == 2) {
                  str = 'acousticness';
                } else if (value == 3) {
                  str = 'instrumentalness';
                } else if (value == 4) {
                  str = 'liveness';
                } else if (value == 5) {
                  str = 'valence';
                } else if (value == 6) {
                  str = 'danceability';
                }

                return Container(
                  margin: EdgeInsets.all(0.0),
                  padding: EdgeInsets.all(5.0),//
                  transform: Matrix4.rotationZ(-0.5),
                  child: Text('$str'),
                );
              },
            ),
            ),
          ),
          borderData: FlBorderData(show: true),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueAccent,
            ),
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }



}

class Album {
  final String id;
  final String name;
  final String artists;
  final String artist_ids;
  final int number_of_tracks;
  final bool explicit;
  final double danceability;
  final double energy;
  final int key;
  final double loudness;
  final int mode;
  final double speechiness;
  final double acousticness;
  final double instrumentalness;
  final double liveness;
  final double valence;
  final double tempo;
  final int duration_ms;
  final int time_signature;
  final int year;
  final int month;
  final int day;
  final int owner_id;

  Album({
    required this.id,
    required this.name,
    required String artists,
    required String artist_ids,
    required this.number_of_tracks,
    required this.explicit,
    required this.danceability,
    required this.energy,
    required this.key,
    required this.loudness,
    required this.mode,
    required this.speechiness,
    required this.acousticness,
    required this.instrumentalness,
    required this.liveness,
    required this.valence,
    required this.tempo,
    required this.duration_ms,
    required this.time_signature,
    required this.year,
    required this.month,
    required this.day,
    required this.owner_id,
  }): artists = artists.replaceAll("'","" ).replaceAll("[","" ).replaceAll("]","" ),
        artist_ids = artist_ids.replaceAll("'","" ).replaceAll("[","" ).replaceAll("]","" );

  Future<String> getAlbumCoverByIdFromCsv(String id) async {
    final String url = 'https://embed.spotify.com/oembed?url=https%3A%2F%2Fopen.spotify.com%2Falbum%2F$id';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(
            response.body);
        print(responseData);

        String thumbnailUrl = responseData['thumbnail_url'];
        return thumbnailUrl;

      } else {
        // Handle error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return '-';
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return '-';
    }
  } // currently used cover function

  Color getVibeColor_energy() {
    // Adjust the weights based on the importance of each characteristic
    double weightedValue = energy ;
    // Map the weighted value to the hue in HSL color space
    double hue = (1.0 - weightedValue) * 120.0; // Adjust the multiplier for a different hue range

    // Create a vibrant color based on the hue
    Color color = HSLColor.fromAHSL(1.0, hue, 1.0, 0.5).toColor();

    return color;
  }



  Widget getCharacteristicsChart() {
    return Container(
      height: 600, // Set the desired height for the chart
      width: 400,
      child: BarChart(
        BarChartData(

          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: energy,
                  color: Colors.blueAccent[200] ,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: speechiness,
                  color: Colors.greenAccent[200] ,
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: acousticness,
                  color: Colors.orangeAccent[200] ,
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: instrumentalness,
                  color: Colors.blueAccent[400] ,
                ),
              ],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(
                  toY: liveness,
                  color: Colors.greenAccent[400] ,
                ),
              ],
            ),
            BarChartGroupData(
              x: 5,
              barRods: [
                BarChartRodData(
                  toY: valence,
                    color: Colors.orangeAccent[400]
                ),
              ],
            ),
            BarChartGroupData(
              x: 6,
              barRods: [
                BarChartRodData(
                  toY: danceability,
                    color: Colors.blueAccent[600]
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String str = '';
                if (value == 0) {
                  str = 'energy';
                } else if (value == 1) {
                  str = 'speechiness';
                } else if (value == 2) {
                  str = 'acousticness';
                } else if (value == 3) {
                  str = 'instrumentalness';
                } else if (value == 4) {
                  str = 'liveness';
                } else if (value == 5) {
                  str = 'valence';
                } else if (value == 6) {
                  str = 'danceability';
                }

                return Container(
                  margin: EdgeInsets.all(0.0),
                  padding: EdgeInsets.all(5.0),//
                  transform: Matrix4.rotationZ(-0.5),
                  child: Text('$str'),
                );
              },
            ),
            ),
          ),
          borderData: FlBorderData(show: true),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueAccent,
            ),
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }

}

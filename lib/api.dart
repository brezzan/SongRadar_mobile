import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000'; //

  Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
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
  }

  Future<Map<String, dynamic>> signUpUser(
      String username, String email, String password) async {
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

  Future<List<Map<String, dynamic>>> getAlbums() async {
    // get albums and the songs they contain
    final String url = '$baseUrl/debug/albums?skip=0&limit=100';
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
  }

  Future<Map<String, dynamic>> createAlbum(
      String album, String performers, int year, String genre) async {
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
    } catch (error) {
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

  Future<Map<String, dynamic>> createSong(String title, String performers,
      int year, String genre, int album_id) async {
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

  //////////////////////////////////////////////////////SONGS FROM CSV ///////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> getSongsFromCsv() async {
    // id,name,album,album_id,artists,artist_ids,track_number,
    // disc_number,explicit,danceability,energy,key,loudness,mode,
    // speechiness,acousticness,instrumentalness,liveness,valence,
    // tempo,duration_ms,time_signature,year,release_date

    // script.py functions are not within virtenv' reach so ı will just red the files directly ,
    // if updated uncomment the section below and delete the current section
    try {
    String csvContent = await rootBundle.loadString('assets/songs_0.csv');

    // Parse the CSV data
    List<List<dynamic>> csvData = CsvToListConverter().convert(csvContent);
    List<Map<String, dynamic>> songsList = csvData
        .map((List<dynamic> row) => Map.fromIterables([
      'id',
      'name',
      'album',
      'album_id',
      'artists',
      'artist_ids',
      'track_number',
      'disc_number',
      'explicit',
      'danceability',
      'energy',
      'key',
      'loudness',
      'mode',
      'speechiness',
      'acousticness',
      'instrumentalness',
      'liveness',
      'valence',
      'tempo',
      'duration_ms',
      'time_signature',
      'year',
      'release_date'
    ], row))
        .toList();

    // Return only the first 20 rows
    return songsList.take(20).toList();
  } catch (e) {
  throw Exception('Failed to read songs data: $e');
  }

  }

/* List<Map<String, dynamic>> songsList = csvData
          .map((List<dynamic> row) => Map.fromIterables([
                'id',
                'name',
                'album',
                'album_id',
                'artists',
                'artist_ids',
                'track_number',
                'disc_number',
                'explicit',
                'danceability',
                'energy',
                'key',
                'loudness',
                'mode',
                'speechiness',
                'acousticness',
                'instrumentalness',
                'liveness',
                'valence',
                'tempo',
                'duration_ms',
                'time_signature',
                'year',
                'month',
                'day'
              ], row))
          .toList(); */

  Future<Map<String, dynamic>> getSongByNameFromCsv(String songName) async {
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

  Future<Map<String, dynamic>> getSongByArtistFromCsv(String artistName) async {
    final String url =
        '$baseUrl/songs/search_artist?artist=$artistName&skip=0&limit=10';
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

  Future<String> getSongCountFromCsv() async {
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
        final String responseData = jsonDecode(response.body);
        print('number of songs in the csv is $responseData');
        return responseData;
      } else {
        // Handle signup error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return 'non 200 response';
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return 'error caught';
    }
  }

  Future<Map<String, dynamic>> getSongByIdFromCsv(int id) async {
    final String url = '$baseUrl/songs/{$id}';
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

/////////////////////////////////////////////////////ALBUMS FROM CSV ///////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> getAlbumsFromCsv() async {
    final String url = '$baseUrl/albums/?skip=0&limit=10';
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
          {'error': response.body}
        ];
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [
        {'error': 'An unexpected error occurred.'}
      ];
    }
  }

  Future<Map<String, dynamic>> getAlbumByNameFromCsv(String albumName) async {
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

  Future<Map<String, dynamic>> getAlbumByArtistFromCsv(
      String artistName) async {
    final String url =
        '$baseUrl/albums/search_artist?artist=$artistName&skip=0&limit=10';
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

  Future<String> getAlbumCountFromCsv() async {
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
        final String responseData = jsonDecode(response.body);
        print('number of albums in the csv is $responseData');
        return responseData;
      } else {
        // Handle signup error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return 'non 200 response';
      }
    } catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return 'error caught';
    }
  }

  Future<Map<String, dynamic>> getAlbumByIdFromCsv(int id) async {
    final String url = '$baseUrl/albums/{$id}';
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
}



/*
    // getsongsfromcsv apply when api uptaded
    final String url = '$baseUrl/songs/?skip=0&limit=10';

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

          var i = 0;
          for (var songJson in songsJson) {
            if (i < 10) {
              songs.add(Map<String, dynamic>.from(songJson));
              i = i + 1;
            }
          }
          return songs; //return albums
        } else {
          return [];
        }
    }
    catch (error) {
      // Handle network or unexpected errors
      print('Error: $error');
      return [{'error': 'An unexpected error occurred.'}];
    }

 */
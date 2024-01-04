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
  }

  Future<Map<String, dynamic>> createAlbum(String album, String performers,
      int year, String genre) async {
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

  Future<List<Map<String, dynamic>>> getSongsFromCsv() async {  //works
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

        for (var songJson in songsJson) {
          // Add each song directly without checking the index
          songs.add(Map<String, dynamic>.from(songJson));
        }

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

  Future<List<dynamic>> getSongByNameFromCsv(String songName) async { //works
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

  Future<int> getSongCountFromCsv() async {  // works
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

  Future<Map<String, dynamic>> getSongByIdFromCsv(String id) async {
    final String url = '$baseUrl/songs/$id'; // Corrected the URL
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


/////////////////////////////////////////////////////ALBUMS FROM CSV ///////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> getAlbumsFromCsv() async {  // works
    final String url = '$baseUrl/albums/?skip=0&limit=30';
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


  Future<List<dynamic>> getAlbumByNameFromCsv(String albumName) async {  //works
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

  Future<List<Map<String, dynamic>>> getAlbumByArtistFromCsv(
      String artistName) async {
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


  Future<int> getAlbumCountFromCsv() async {  // works
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

  Future<Map<String, dynamic>> getAlbumByIdFromCsv(String id) async {   // works
    final String url = '$baseUrl/albums/$id';
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



}

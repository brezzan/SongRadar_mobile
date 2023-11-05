import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl =
      'http://10.0.2.2:8000'; // Replace with your actual API base URL

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

        // Include the access token in the headers for future requests

        // You can return the access token or use it as needed
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

  Future<Map<String, dynamic>> getUser( String accessToken) async {
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

  Future<Map<String, dynamic>> signUpUser( String username, String email, String password) async {
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

}

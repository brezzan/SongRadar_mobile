import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';



class SqlHelper{
  var encrypt, decrypt;
  var key ="null";

  static Future<void>Encrypt()async{}
  static Future<void>Decrypt()async{}

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS users(
  id INTEGER NOT NULL,
  username VARCHAR,
  email VARCHAR,
  hashed_password VARCHAR) """);
  }

  static Future<sql.Database> db() async {
    final path = await sql.getDatabasesPath();
    final dbPath = join(path, 'sql.db');
    print('Database path: $dbPath');

    if (await File(dbPath).exists()) {
      print('Database exists');
    } else {
      print('No database');
    }

    return sql.openDatabase(dbPath, version: 2, onCreate: (sql.Database database, int version)
    async { await createTables(database); });
  }

  static Future<List<Map<String, dynamic>>> seeAll() async {
    final db = await SqlHelper.db();
    final path = await sql.getDatabasesPath();
    final result = await db.rawQuery("""SELECT * FROM users """);
    return result;

  }

  static Future<void> dbPath() async {
    final dbPath = join(await sql.getDatabasesPath(), 'sql.db');
    print('Database path: $dbPath');

    if (await sql.databaseExists(dbPath)) {
      // print('Database exists');
    } else {
      print('no database here');

    }
  }

  static Future<void> copyAsset() async {
    // Get the data directory for the app
    String dataDir = await sql.getDatabasesPath();
    String dbPath = join(dataDir, 'sql.db');

    // Check if the database file already exists
    if (await File(dbPath).exists()) {
      print('Database already exists');
      return;
    }

    // Copy the database file from assets to the data directory
    ByteData data = await rootBundle.load('db/sql.db');
    List<int> bytes = data.buffer.asUint8List();
    await File(dbPath).writeAsBytes(bytes);

    print('Database copied to: $dbPath');
  }

  static Future<int> addNewUser(String username, String password, String mail) async{ // sign up
    final db = await SqlHelper.db();

    final new_user = {'username': username,'hashed_password': password, 'email':mail};
    final id = await db.insert('users',new_user,conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }


  static Future<List<Map<String, dynamic>>> searchUser(String username, String password) async {
    try {
      final db = await SqlHelper.db();
      final path = await sql.getDatabasesPath();
      //print("Database path in searchUser: $path");

      final result = await db.rawQuery(
        'SELECT * FROM users WHERE username = ? AND hashed_password = ?',
        [username, password],
      );

      return result;
    } catch (e) {
      print("Error in searchUser: $e");
      return [];
    }
  }
/*
  static Future<void> fetchData() async {
  final response = await http.get(Uri.parse('http://127.0.0.1:8000/docs#/auth/sign_in'));
  if (response.statusCode == 200) {
    // Handle successful response
    print('Response data: ${response.body}');
  } else {
    // Handle errors
    print('Error: ${response.statusCode}');
  }
}

  static Future<List<Map<String, dynamic>>> searchUser(String username, String password) async {
    try {
      final db = await SqlHelper.db();
      final path = await sql.getDatabasesPath();

      final result = await db.rawQuery(
        'SELECT * FROM users WHERE username = ? AND hashed_password = ?',
        [username, password],
      );

      if (result.isNotEmpty) {
        final storedPassword = result.first['hashed_password'] as String;

        if (Bcrypt.verify(password, storedPassword)) {
          print('Password match');  // You can remove this line once it works

          // You might want to return user data instead of the raw result
          return result;
        } else {
          print('Password does not match');
        }
      }

      return [];
    } catch (e) {
      print("Error in searchUser: $e");
      return [];
    }
  }

 */
}
import 'package:flutter/material.dart';
import 'package:frontend/Pages/signup.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'B-Naeng.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT)',
        );
      },
    );
  }

  // Future<void> insertUser(String name, String email) async {
  //   final db = await database;
  //   await db.insert(
  //     'users',
  //     {'name': name, 'email': email},
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

    Future<void> insertUser(String name, String email, String nickname, String birthday, String gender, String recommender) async {
    final db = await database;
    await db.insert(
      'users',
      {'name': name, 'email': email, "nickname" : nickname, "birthday" : birthday, "gender" : gender, "recommender" : recommender, },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String email) async {
    final db = await database;
    List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return users.isNotEmpty ? users.first : null;
  }
}

class SignInPage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // 로그인 취소 시 null 반환

      final String username = googleUser.displayName ?? '';
      final String email = googleUser.email;

      // SQLite에 사용자 정보 확인
      Map<String, dynamic>? existingUser = await _dbHelper.getUser(email);
      if (existingUser == null) {
        // 회원가입 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignupPage1(username: username, email: email),
          ),
        );
      } else {
        // 이미 존재하는 경우 로그인 처리
        print("User already exists. Proceed with login.");
      }
    } catch (error) {
      print("Error signing in with Google: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signInWithGoogle(context),
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}

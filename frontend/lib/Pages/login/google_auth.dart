import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/Pages/login/signup.dart';
import 'package:frontend/Pages/login/signup_complete.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart'; // 카메라 사용을 위한 패키지 추가

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
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT, nickname TEXT, birthday TEXT, gender TEXT, recommender TEXT)',
        );
      },
    );
  }

  Future<void> insertUser(String name, String email, String nickname,
      String birthday, String gender, String recommender) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'name': name,
        'email': email,
        'nickname': nickname,
        'birthday': birthday,
        'gender': gender,
        'recommender': recommender,
      },
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
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final List<CameraDescription> cameras; // cameras 리스트 추가

  SignInPage({super.key, required this.cameras}); // 생성자에 cameras 추가

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // 로그인 취소

      final String username = googleUser.displayName ?? '';
      final String email = googleUser.email;

      // SQLite에서 기존 사용자 확인
      Map<String, dynamic>? existingUser = await _dbHelper.getUser(email);
      if (existingUser == null) {
        // 사용자가 존재하지 않으면 가입 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignupPage1(username: username, email: email),
          ),
        );
      } else {
        // 사용자가 존재하면 로그인 진행
        print("사용자가 이미 존재합니다. 로그인 진행.");

        // 서버에서 액세스 토큰 가져오기
        final String accessToken = await _loginAndFetchToken(email);
        if (accessToken.isNotEmpty) {
          await storage.write(key: 'access_token', value: accessToken);

          // 사용자가 이미 존재하므로 SignupComplete 페이지로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SignupComplete(cameras: cameras), // 필요에 따라 cameras 전달
            ),
          );
        }
      }
    } catch (error) {
      print("구글 로그인 중 오류 발생: $error");
    }
  }

  Future<String> _loginAndFetchToken(String email) async {
    return "access_token 반환하도록 코드 수정";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff8EC96D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: screenHeight * 0.1,
            ),
            GestureDetector(
              child: SvgPicture.asset(
                'assets/images/B-Naeng_logo.svg',
                width: screenWidth * 0.5,
              ),
            ),
            SizedBox(
              height: screenHeight * 0.15,
            ),
            GestureDetector(
              onTap: () => _signInWithGoogle(context),
              child: SvgPicture.asset(
                'assets/images/ios_neutral_sq_SignInWithGoogle.svg',
                width: screenWidth * 0.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

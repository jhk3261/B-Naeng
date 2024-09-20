import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/Pages/receipe_recommend.dart';
// import 'package:frontend/Pages/friger.dart';
import 'package:frontend/Pages/signup.dart'; // github에 올릴 때 지우기
// import 'package:frontend/Pages/google_login.dart';
import 'package:frontend/Pages/google_auth.dart';

void main() async {
  // 카메라 초기화
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  runApp(MaterialApp(
    theme: ThemeData(
<<<<<<< HEAD
        textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'GmarketSansLight'),
      bodyMedium: TextStyle(fontFamily: 'GmarketSansMedium'),
      headlineLarge: TextStyle(fontFamily: 'GmarketSansBold'),
    )),
    // home: Friger(cameras: cameras),
    // home: GoogleLoginPage(),
    home: SignInPage(),
    // home: ReceipeRecommend(cameras: cameras),
=======
      fontFamily: 'GmarketSansMedium',
    ),
    themeMode: ThemeMode.system,
    home: Friger(cameras: cameras),
>>>>>>> main
  ));
}

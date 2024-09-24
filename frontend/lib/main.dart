import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
// import 'package:frontend/Pages/friger/friger.dart';
import 'package:frontend/Pages/login/google_auth.dart';
import 'package:frontend/Pages/login/signup.dart';

void main() async {
  // 카메라 초기화
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: 'GmarketSansMedium',
    ),
    themeMode: ThemeMode.system,
    // home: Friger(cameras: cameras),
    home: SignInPage(),
    // home: SignupPage1(username: '서지원', email: 'wldnjstj99@gmail.com'),
  ));
}

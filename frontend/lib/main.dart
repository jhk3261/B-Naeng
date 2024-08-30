import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/Pages/friger.dart';

void main() async {
  // 카메라 초기화
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  runApp(MaterialApp(
    theme: ThemeData(
        textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'GmarketSansLight'),
      bodyMedium: TextStyle(fontFamily: 'GmarketSansMedium'),
      headlineLarge: TextStyle(fontFamily: 'GmarketSansBold'),
    )),
    home: Friger(cameras: cameras),
  ));
}

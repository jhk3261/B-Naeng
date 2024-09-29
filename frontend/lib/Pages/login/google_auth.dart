import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/Pages/login/signup.dart';
import 'package:frontend/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert';
import 'package:camera/camera.dart';

class SignInPage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final List<CameraDescription> cameras;

  SignInPage({super.key, required this.cameras});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // 로그인 취소

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String accessToken = googleAuth.accessToken!; 
      final String email = googleUser.email;

      // 이메일로 토큰 생성 후 storage에 저장
      await storage.write(
          key: 'access_token', value: accessToken); 

      // 사용자 조회
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/valid/user?email=$email'),
      );

      if (response.statusCode == 200) {
        final bool userExists = json.decode(response.body); 
        if (userExists) {
          // 홈으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(cameras: cameras),
            ),
          );
        } else {
          // 회원가입으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignupPage1(
                  username: googleUser.displayName ?? '', email: email, cameras: cameras,),
            ),
          );
        }
      } else {
        print("서버 응답 오류: ${response.statusCode}");
      }
    } catch (error) {
      print("구글 로그인 중 오류 발생: $error");
    }
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
            SizedBox(height: screenHeight * 0.1),
            GestureDetector(
              child: SvgPicture.asset(
                'assets/images/B-Naeng_logo.svg',
                width: screenWidth * 0.5,
              ),
            ),
            SizedBox(height: screenHeight * 0.15),
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

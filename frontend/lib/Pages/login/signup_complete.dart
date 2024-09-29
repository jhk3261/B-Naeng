import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/main.dart'; // HomeScreen을 불러오기 위해 main.dart도 import

class SignupComplete extends StatelessWidget {
  final List<CameraDescription> cameras; // 카메라 정보를 받아야 함

  const SignupComplete({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const FlutterSecureStorage storage = FlutterSecureStorage();

    Future<Map<String, dynamic>?> getUserInfo() async {
      final token = await storage.read(key: 'access_token');
      if (token == null) return null;

      // JWT를 '.'로 분리하여 Payload 부분을 가져옵니다.
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Payload 부분을 Base64로 디코딩합니다.
      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));
      
      // JSON으로 변환합니다.
      return json.decode(decodedPayload);
    }

    return Scaffold(
      body: Center(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: getUserInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const Text('No token found or invalid token');
            }

            final userInfo = snapshot.data!;
            final user = userInfo['user'] ?? 'Unknown'; // JWT에서 사용자 이름 추출
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/signup_complete.svg',
                  width: screenWidth * 0.5,
                ),
                const SizedBox(height: 20),
                Text(user), // 사용자 이름 표시
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // HomeScreen으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(cameras: cameras), // HomeScreen으로 이동
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth * 0.84, 50),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    backgroundColor: const Color(0xff449C4A),
                  ),
                  child: Text(
                    '비냉 시작하기',
                    style: TextStyle(
                      color: const Color(0xffffffff),
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
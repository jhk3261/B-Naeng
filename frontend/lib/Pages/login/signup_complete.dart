import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:camera/camera.dart';

class SignupComplete extends StatelessWidget {
  final List<CameraDescription> cameras;
  const SignupComplete({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // SecureStorage
    const FlutterSecureStorage storage = FlutterSecureStorage();

    // 사용자 정보를 가져오는 기존 함수 토큰 파싱
    Future<Map<String, dynamic>?> getUserInfo() async {
      final token = await storage.read(key: 'access_token');
      if (token == null) return null;

      // JWT로 payload 불러오기
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));

      // Json 으로 변환 후 반환
      return json.decode(decodedPayload);
    }

    // 토큰을 가져와서 서버에 전송 후 사용자 정보를 받아오기
    Future<void> fetchAndPrintUserInfo() async {
      final token = await storage.read(key: 'access_token');
      if (token == null) {
        return;
      }

      try {
        final response = await http.get(
          Uri.parse('http://127.0.0.1:8000/load/userinfo'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final userData = json.decode(response.body);
        } else {}
      } catch (e) {}
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
                  onPressed: () async {
                    await fetchAndPrintUserInfo();
                    // HomeScreen으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(cameras: cameras),
                      ),
                    );
                    // Navigator.of(context).pushAndRemoveUntil(
                    //   MaterialPageRoute(
                    //     builder: (_) =>
                    //         HomeScreen(cameras: cameras), // HomeScreen으로 이동
                    //   ),
                    //   (route) => route.settings.name == '/',
                    // );
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

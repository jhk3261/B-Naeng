import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/Pages/login/google_auth.dart';

class SignupComplete extends StatelessWidget {
  const SignupComplete({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: screenWidth * 0.2,
            ),
            GestureDetector(
              child: SvgPicture.asset(
                'assets/images/signup_complete.svg',
                width: screenWidth * 0.5,
              ),
            ),
            SizedBox(
              height: screenHeight * 0.15,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInPage(),
                  ), // 메인페이지로 이동하도록 수정하기!
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
        ),
      ),
    );
  }
}

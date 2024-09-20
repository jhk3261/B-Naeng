import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLoginPage extends StatefulWidget {
  @override
  _GoogleLoginPageState createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? _userEmail;
  String? _userName;

  Future<void> _handleGoogleSignIn() async {
    try {
      // Google 로그인
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // 사용자가 로그인 취소
        return;
      }

      // 로그인된 사용자 정보 가져오기
      setState(() {
        _userEmail = googleUser.email;
        _userName = googleUser.displayName;
      });
    } catch (error) {
      print('Google Sign In failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Sign In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _handleGoogleSignIn,
              child: Text('Sign in with Google'),
            ),
            SizedBox(height: 20),
            if (_userEmail != null && _userName != null)
              Column(
                children: [
                  Text('Email: $_userEmail'),
                  Text('Name: $_userName'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

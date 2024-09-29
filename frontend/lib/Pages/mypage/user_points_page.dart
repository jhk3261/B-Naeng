import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiUrl = 'http://127.0.0.1:8000';

class UsePointsPage extends StatefulWidget {
  final int userId;
  final Function() onRefresh;

  const UsePointsPage(
      {super.key, required this.userId, required this.onRefresh});

  @override
  _UsePointsPageState createState() => _UsePointsPageState();
}

class _UsePointsPageState extends State<UsePointsPage> {
  late Future<UserProfile> userProfileFuture;
  int selectedPoints = 10000;
  String? message;

  @override
  void initState() {
    super.initState();
    userProfileFuture = fetchUserProfile(widget.userId);
  }

  Future<UserProfile> fetchUserProfile(int userId) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/mypage/$userId'));
      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body));
      }
    } catch (_) {
      return UserProfile(
        id: 0,
        userId: userId,
        username: '기본 사용자',
        profileImageUrl: null,
        greenPoints: 0,
        fridgeCount: 0,
      );
    }
    return UserProfile(
      id: 0,
      userId: userId,
      username: '기본 사용자',
      profileImageUrl: null,
      greenPoints: 0,
      fridgeCount: 0,
    );
  }

  Future<void> usePoints(int userId, int points) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/use_points'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'points': points,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          message = '포인트 사용이 완료되었습니다.';
        });
        // 포인트 사용 후 사용자 프로필을 다시 불러옵니다.
        userProfileFuture = fetchUserProfile(userId);
      } else {
        setState(() {
          message = '포인트 사용 중 문제가 발생했습니다. 상태 코드: ${response.statusCode}';
        });
      }
    } catch (_) {
      setState(() {
        message = '서버와의 통신에 실패했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.black,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "포인트 사용하기",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<UserProfile>(
          future: userProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                  child: Text('프로필 정보를 불러오는 데 실패했습니다.',
                      style: TextStyle(fontFamily: 'GmarketSansMedium')));
            } else {
              final profile = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '보유 중인 그린 포인트',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'GmarketSansMedium',
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${profile.greenPoints}',
                        style: const TextStyle(
                          fontSize: 26,
                          color: Colors.green,
                          fontFamily: 'GmarketSansBold',
                        ),
                      ),
                      const Text(
                        ' 점',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'GmarketSansMedium',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildPointsList(),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedPoints > 0) {
                          usePoints(profile.userId!, selectedPoints);
                        } else {
                          setState(() {
                            message = '유효한 포인트를 선택해주세요.';
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            const Size(double.infinity, 55), // 가로 길이 일치
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '변경하기',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'GmarketSansMedium',
                        ),
                      ),
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      message!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: 'GmarketSansMedium',
                      ),
                    ),
                  ],
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPointsList() {
    List<int> pointOptions = [10000, 20000, 30000, 40000, 50000];
    return Column(
      children: pointOptions.map((points) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: RadioListTile<int>(
            title: Text(
              '$points원',
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'GmarketSansMedium',
              ),
            ),
            value: points,
            groupValue: selectedPoints,
            activeColor: Colors.green,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: selectedPoints == points
                      ? Colors.green
                      : Colors.grey), // 테두리 초록색
              borderRadius: BorderRadius.circular(10),
            ),
            tileColor: selectedPoints == points ? Colors.green[50] : null,
            onChanged: (int? value) {
              setState(() {
                selectedPoints = value ?? 0;
              });
            },
          ),
        );
      }).toList(),
    );
  }
}

class UserProfile {
  final int id;
  final int? userId; // nullable로 변경
  final String? username;
  final String? profileImageUrl;
  final int greenPoints;
  final int fridgeCount;

  UserProfile({
    required this.id,
    this.userId,
    this.username,
    this.profileImageUrl,
    required this.greenPoints,
    required this.fridgeCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      userId: json['user_id'],
      username: json['username'],
      profileImageUrl: json['profile_image_url'],
      greenPoints: json['green_points'],
      fridgeCount: json['fridge_count'],
    );
  }
}

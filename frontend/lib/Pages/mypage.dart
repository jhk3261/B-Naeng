import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'fridge_popup.dart';
import 'user_points_page.dart';

const String apiUrl = 'http://127.0.0.1:8000';

class MyPage extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyPage({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(cameras: cameras);
  }
}

class ProfilePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const ProfilePage({super.key, required this.cameras});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserProfile> userProfileFuture;
  int userId = 1004;
  bool isScrapExpanded = false;

  @override
  void initState() {
    super.initState();
    userProfileFuture = fetchUserProfile(userId);
  }

  Future<UserProfile> fetchUserProfile(int userId) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/mypage/$userId'));
      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (error) {
      print('Error fetching user profile: $error');
      return UserProfile(
        id: 0,
        userId: userId,
        username: '기본 사용자',
        profileImageUrl: null,
        greenPoints: 0,
        fridgeCount: 0,
      );
    }
  }

  Future<List<ScrapItem>> fetchScrapItems(int? userId) async {
    if (userId == null) {
      return [];
    }

    try {
      final response = await http.get(Uri.parse('$apiUrl/scrap_items/$userId'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => ScrapItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load scrap items');
      }
    } catch (error) {
      print('Error fetching scrap items: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserProfile>(
        future: userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('사용자 정보를 불러오지 못했습니다.'));
          } else {
            final profile = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildProfileSection(profile),
                  const SizedBox(height: 16),
                  buildGreenPointsSection(profile),
                  const SizedBox(height: 16),
                  buildFridgeSection(profile),
                  const SizedBox(height: 16),
                  buildScrapSection(profile.userId),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildProfileSection(UserProfile profile) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/profile.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          profile.username ?? '기본 사용자',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget buildGreenPointsSection(UserProfile profile) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFE1EFE2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            '그린 포인트',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${profile.greenPoints}',
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'GmarketSansBold',
              color: Color(0xFF449C4A),
            ),
          ),
          const Text(
            ' 점',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UsePointsPage(userId: profile.userId),
                ),
              );
            },
            child: const Text(
              '사용하기',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFridgeSection(UserProfile profile) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.transparent,
                child: Image(
                  image: AssetImage('assets/images/fridge.png'),
                  width: 43,
                  height: 43,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '냉장고',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${profile.fridgeCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '대',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 16),
          const Row(
            children: [
              SizedBox(width: 4),
              Image(
                image: AssetImage('assets/images/rightArrow.png'),
                width: 18,
                height: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildScrapSection(int? userId) {
    return FutureBuilder<List<ScrapItem>>(
      future: fetchScrapItems(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1EFE2),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Image(
                          image: AssetImage('assets/images/star.png'),
                          width: 16,
                          height: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '스크랩',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isScrapExpanded = !isScrapExpanded;
                        });
                      },
                      child: Image(
                        image: AssetImage(isScrapExpanded
                            ? 'assets/images/upArrow.png'
                            : 'assets/images/downArrow.png'),
                        width: 16,
                        height: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '스크랩된 항목이 없습니다.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          );
        } else {
          List<ScrapItem> scrapItems = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1EFE2),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Image(
                          image: AssetImage('assets/images/star.png'),
                          width: 18,
                          height: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '스크랩',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isScrapExpanded = !isScrapExpanded;
                        });
                      },
                      child: Image(
                        image: AssetImage(isScrapExpanded
                            ? 'assets/images/upArrow.png'
                            : 'assets/images/downArrow.png'),
                        width: 16,
                        height: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              isScrapExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: scrapItems.map((item) {
                        return ListTile(
                          title: Text(item.title),
                          subtitle: Text(item.description),
                        );
                      }).toList(),
                    )
                  : const SizedBox.shrink(),
            ],
          );
        }
      },
    );
  }
}

class UserProfile {
  final int id;
  final int userId;
  final String? username;
  final String? profileImageUrl;
  final int greenPoints;
  final int fridgeCount;

  UserProfile({
    required this.id,
    required this.userId,
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

class ScrapItem {
  final String title;
  final String description;

  ScrapItem({required this.title, required this.description});

  factory ScrapItem.fromJson(Map<String, dynamic> json) {
    return ScrapItem(
      title: json['title'],
      description: json['description'],
    );
  }
}

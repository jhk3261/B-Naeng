import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/pages/receipe_recommend.dart';
import 'package:frontend/pages/share_ingredient.dart';
import 'package:frontend/pages/friger.dart';
import 'package:frontend/pages/chat_room.dart';
import 'package:frontend/pages/user_points_page.dart';
import 'package:frontend/pages/fridge_popup.dart';

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
  bool isScrapExpanded = false;
  late Future<UserProfile> userProfile;
  late Future<List<ScrapItem>> scrapItems;

  @override
  void initState() {
    super.initState();
    userProfile = fetchUserProfile();
    scrapItems = fetchScrapItems();
  }

  Future<UserProfile> fetchUserProfile() async {
    final response = await http.get(Uri.parse('$apiUrl/mypage/1')); // userId를 1로 예시, 실제 값 사용 필요
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<List<ScrapItem>> fetchScrapItems() async {
    final response = await http.get(Uri.parse('$apiUrl/scrap_items/1')); // userId를 1로 예시, 실제 값 사용 필요
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ScrapItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load scrap items');
    }
  }

  void toggleScrapSection() {
    setState(() {
      isScrapExpanded = !isScrapExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                FutureBuilder<UserProfile>(
                  future: userProfile,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final profile = snapshot.data!;
                      return buildProfileSection(profile);
                    } else {
                      return Center(child: Text('No data available'));
                    }
                  },
                ),
                const SizedBox(height: 15),
                FutureBuilder<UserProfile>(
                  future: userProfile,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final profile = snapshot.data!;
                      return buildGreenPoints(context, profile);
                    } else {
                      return Center(child: Text('No data available'));
                    }
                  },
                ),
                const SizedBox(height: 30),
                FutureBuilder<UserProfile>(
                  future: userProfile,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final profile = snapshot.data!;
                      return buildFridgeSection(context, profile);
                    } else {
                      return Center(child: Text('No data available'));
                    }
                  },
                ),
                const SizedBox(height: 16),
                buildScrapSection(),
                if (isScrapExpanded) FutureBuilder<List<ScrapItem>>(
                  future: scrapItems,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final items = snapshot.data!;
                      return buildScrapList(items);
                    } else {
                      return Center(child: Text('No data available'));
                    }
                  },
                ),
              ],
            ),
          ),
          buildBottomNav(context),
        ],
      ),
    );
  }

  // 프로필 섹션
  Widget buildProfileSection(UserProfile profile) {
    return Container(
      width: double.infinity,
      height: 150,
      color: const Color(0xFFF8F8F8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(profile.profileImageUrl),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '홍길동', // 실제 사용자 이름으로 변경 필요
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'GmarketSansBold',
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '님',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'GmarketSansMedium',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 그린 포인트 섹션
  Widget buildGreenPoints(BuildContext context, UserProfile profile) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFFE1EFE2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            '그린 포인트',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'GmarketSansMedium',
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              '${profile.greenPoints} 점',
              style: const TextStyle(
                fontSize: 17,
                fontFamily: 'GmarketSansBold',
                color: Color(0xFF449C4A),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UsePointsPage()), // const 제거
              );
            },
            child: const Text(
              '사용하기',
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'GmarketSansMedium',
                color: Color.fromARGB(255, 159, 159, 159),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 냉장고 섹션
  Widget buildFridgeSection(BuildContext context, UserProfile profile) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.transparent,
                child: Image.asset(
                  'assets/images/fridge.png',
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
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'GmarketSansMedium',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${profile.fridgeCount} 대',
                    style: const TextStyle(
                      fontSize: 17,
                      fontFamily: 'GmarketSansBold',
                    ),
                  ),
                  const SizedBox(width: 3),
                  GestureDetector(
                    onTap: () => showFridgeDetails(context),
                    child: Image.asset(
                      'assets/images/rightArrow.png',
                      width: 18,
                      height: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 스크랩 섹션
  Widget buildScrapSection() {
    return GestureDetector(
      onTap: toggleScrapSection,
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFFE1EFE2),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/star.png',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 9),
                const Text(
                  '스크랩',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'GmarketSansMedium',
                  ),
                ),
              ],
            ),
            Image.asset(
              isScrapExpanded
                  ? 'assets/images/upArrow.png'
                  : 'assets/images/downArrow.png',
              width: 18,
              height: 18,
            ),
          ],
        ),
      ),
    );
  }

  // 스크랩 리스트
  Widget buildScrapList(List<ScrapItem> items) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isScrapExpanded ? 300.0 : 0.0,
      child: Scrollbar(
        thumbVisibility: true,
        thickness: 4.0,
        radius: const Radius.circular(5),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: Image.asset(item.image),
              title: Text(item.title),
              subtitle: Text('${item.likes} likes, ${item.comments} comments, ${item.date}'),
            );
          },
        ),
      ),
    );
  }

  // 하단 네비게이션
  Widget buildBottomNav(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildBottomNavItem(
              context,
              icon: Icons.book,
              label: "레시피",
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReceipeRecommend(cameras: widget.cameras),
                  ),
                );
              },
            ),
            buildBottomNavItem(
              context,
              icon: Icons.people,
              label: "나눔터",
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ShareIngredient(cameras: widget.cameras),
                  ),
                );
              },
            ),
            buildBottomNavItem(
              context,
              icon: Icons.kitchen,
              label: "냉장고",
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Friger(cameras: widget.cameras),
                  ),
                );
              },
            ),
            buildBottomNavItem(
              context,
              icon: Icons.chat,
              label: "비냉톡",
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoom(cameras: widget.cameras),
                  ),
                );
              },
            ),
            buildBottomNavItem(
              context,
              icon: Icons.person,
              label: "내정보",
              isSelected: true,
              onPressed: () {}, // onPressed 필수로 추가
            ),
          ],
        ),
      ),
    );
  }

  // 재사용 가능한 하단 네비게이션 아이템
  Widget buildBottomNavItem(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed,
      bool isSelected = false}) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: isSelected ? const Color(0xFF8EC96D) : Colors.grey),
          onPressed: onPressed,
        ),
        Text(label),
      ],
    );
  }

  // 냉장고 상세보기 팝업
  void showFridgeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const FridgePopup(),
    );
  }
}

// 사용자 프로필 데이터 모델
class UserProfile {
  final String profileImageUrl;
  final int greenPoints;
  final int fridgeCount;

  UserProfile({
    required this.profileImageUrl,
    required this.greenPoints,
    required this.fridgeCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      profileImageUrl: json['profileImageUrl'],
      greenPoints: json['greenPoints'],
      fridgeCount: json['fridgeCount'],
    );
  }
}

// 스크랩 아이템 데이터 모델
class ScrapItem {
  final String image;
  final String title;
  final int likes;
  final int comments;
  final String date;

  ScrapItem({
    required this.image,
    required this.title,
    required this.likes,
    required this.comments,
    required this.date,
  });

  factory ScrapItem.fromJson(Map<String, dynamic> json) {
    return ScrapItem(
      image: json['image'],
      title: json['title'],
      likes: json['likes'],
      comments: json['comments'],
      date: json['date'],
    );
  }
}

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
                buildProfileSection(),
                const SizedBox(height: 15),
                buildGreenPoints(context),
                const SizedBox(height: 30),
                buildFridgeSection(context),
                const SizedBox(height: 16),
                buildScrapSection(),
                if (isScrapExpanded) buildScrapList(),
              ],
            ),
          ),
          buildBottomNav(context),
        ],
      ),
    );
  }

  // 프로필 섹션
  Widget buildProfileSection() {
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
            child: Image.asset('assets/images/profile.png'),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                '홍길동',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'GmarketSansBold',
                ),
              ),
              SizedBox(width: 4),
              Text(
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
  Widget buildGreenPoints(BuildContext context) {
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
          const Expanded(
            child: Text(
              '999 점',
              style: TextStyle(
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
  Widget buildFridgeSection(BuildContext context) {
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
                  const Text(
                    '2 대',
                    style: TextStyle(
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
  Widget buildScrapList() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isScrapExpanded ? 300.0 : 0.0,
      child: Scrollbar(
        thumbVisibility: true,
        thickness: 4.0,
        radius: const Radius.circular(5),
        child: ListView(
          children: const [
            ScrapItem(
                image: 'assets/images/img1.png',
                title: '당근이 남아돌 때 꿀 팁!!',
                likes: 122,
                comments: 65,
                date: '2024.06.28'),
            ScrapItem(
                image: 'assets/images/img2.png',
                title: '쌈 채소 드려요',
                likes: 62,
                comments: 13,
                date: '2024.05.12'),
            ScrapItem(
                image: 'assets/images/img3.png',
                title: '삼겹살 800g',
                likes: 5,
                comments: 0,
                date: '2024.07.12'),
            ScrapItem(
                image: 'assets/images/img4.png',
                title: '아보카도 덮밥 레시피',
                likes: 100,
                comments: 0,
                date: '2024.06.28'),
          ],
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

// 스크랩 아이템 클래스
class ScrapItem extends StatelessWidget {
  final String image;
  final String title;
  final int likes;
  final int comments;
  final String date;

  const ScrapItem({
    Key? key,
    required this.image,
    required this.title,
    required this.likes,
    required this.comments,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(image),
      title: Text(title),
      subtitle: Text('$likes likes, $comments comments, $date'),
    );
  }
}

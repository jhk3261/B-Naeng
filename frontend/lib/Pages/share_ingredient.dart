import 'package:flutter/material.dart';
import 'package:frontend/Pages/friger.dart';
import 'package:frontend/Pages/mypage.dart';
import 'package:frontend/Pages/receipe_recommend.dart';
import 'package:frontend/widgets/food_element.dart';
import 'package:camera/camera.dart';
import 'share_tips.dart';
import 'chat_room.dart';

class ShareIngredient extends StatelessWidget {
  final List<CameraDescription> cameras;

  const ShareIngredient({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> foodElements = [
      {
        'isShared': true,
        'title': '고기 나눠드려요~',
        'imgPath': 'assets/images/beef.jpg',
        'locationDong': '가좌동',
      },
      {
        'isShared': true,
        'title': '등갈비 남은거 가져가세요~',
        'imgPath': 'assets/images/backrip.jpg',
        'locationDong': '초전동',
      },
      {
        'isShared': false,
        'title': '라면 먹고 싶은데 김치가 없어요.. 김치 있으신 분?',
        'imgPath': 'assets/images/kimchi.jpg',
        'locationDong': '금산면',
      },
      {
        'isShared': true,
        'title': '스팸 많이 남아서 뿌립니다!!',
        'imgPath': 'assets/images/spam.jpg',
        'locationDong': '정촌면',
      },
      {
        'isShared': true,
        'title': '햇반 유효기한 두 달 남은거 다섯 팩',
        'imgPath': 'assets/images/rice.jpeg',
        'locationDong': '충무공동',
      }
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "비냉 나눔터",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      "재료 나눔",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF449C4A),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ShareReceipe(cameras: cameras),
                          ),
                        );
                      },
                      child: const Text(
                        "정보 나눔",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFCBCBCB),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Divider(
                  thickness: 1,
                  color: Color(0xFFe5e5e5),
                ),
                const SizedBox(height: 10),
                const SearchBar(
                  hintText: "필요한 식재료명을 입력하세요",
                  elevation: WidgetStatePropertyAll(0),
                  trailing: [Icon(Icons.search)],
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: WidgetStatePropertyAll(Color(0xFFABD8B1)),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 15),
                  ),
                  constraints: BoxConstraints(minHeight: 50),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 5, // 간격 줄이기
                      mainAxisSpacing: 5, // 간격 줄이기
                    ),
                    itemCount: foodElements.length,
                    itemBuilder: (context, index) {
                      final food = foodElements[index];
                      return FoodElement(
                        isShared: food['isShared'],
                        title: food['title'],
                        imgPath: food['imgPath'],
                        locationDong: food['locationDong'],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.book, color: Colors.grey),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReceipeRecommend(cameras: cameras),
                            ),
                          );
                        },
                      ),
                      const Text("레시피"),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.people,
                          color: Color(0xFF8EC96D),
                        ),
                        onPressed: () {},
                      ),
                      const Text("나눔터"),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.kitchen, color: Colors.grey),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Friger(cameras: cameras),
                            ),
                          );
                        },
                      ),
                      const Text("냉장고"),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chat, color: Colors.grey),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoom(cameras: cameras),
                            ),
                          );
                        },
                      ),
                      const Text("비냉톡"),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.person, color: Colors.grey),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyPage(cameras: cameras),
                            ),
                          );
                        },
                      ),
                      const Text("내정보"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

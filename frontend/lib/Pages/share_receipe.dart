import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Pages/chat_room.dart';
import 'package:frontend/Pages/friger.dart';
import 'package:frontend/Pages/mypage.dart';
import 'package:frontend/Pages/receipe_recommend.dart';
import 'package:frontend/Pages/share_ingredient.dart';
import 'package:frontend/widgets/receipe_element.dart';

class ShareReceipe extends StatelessWidget {
  final List<CameraDescription> cameras;

  const ShareReceipe({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> receipes = [
      {
        'isShared': true,
        'title': '소고기 요리 꿅팁 방출~',
        'imgPath': 'assets/images/beef.jpg',
        'locationDong': '가좌동',
      },
      {
        'isShared': true,
        'title': '등갈비, 이렇게하면 뼈가 쏙쏙 빠져요~',
        'imgPath': 'assets/images/backrip.jpg',
        'locationDong': '초전동',
      },
      {
        'isShared': false,
        'title': '라면과 최고 조합인 김치는?!!!!',
        'imgPath': 'assets/images/kimchi.jpg',
        'locationDong': '금산면',
      },
      {
        'isShared': true,
        'title': '스팸으로 만드는 10가지 요리법',
        'imgPath': 'assets/images/spam.jpg',
        'locationDong': '정촌면',
      },
      {
        'isShared': true,
        'title': '햇반으로 만드는 고슬고슬 황금밥알 볶음밥',
        'imgPath': 'assets/images/rice.jpeg',
        'locationDong': '충무공동',
      }
    ];

    return MaterialApp(
      home: Scaffold(
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
                      GestureDetector(
                        // 수정
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShareIngredient(cameras: cameras),
                            ),
                          );
                        },
                        child: const Text(
                          "재료 나눔",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFCBCBCB),
                          ),
                        ),
                      ),
                      const Text(
                        "레시피 나눔",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF449C4A),
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
                    hintText: "궁금한 요리명을 입력하세요",
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
                        crossAxisCount: 1,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 5, // 간격 줄이기
                        mainAxisSpacing: 5, // 간격 줄이기
                      ),
                      itemCount: receipes.length,
                      itemBuilder: (context, index) {
                        final r = receipes[index];
                        return ReceipeShareElement(
                          isShared: r['isShared'],
                          title: r['title'],
                          imgPath: r['imgPath'],
                          locationDong: r["locationDong"],
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
                                builder: (context) =>
                                    ChatRoom(cameras: cameras),
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
      ),
    );
  }
}

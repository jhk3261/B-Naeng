import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Pages/tip_detail.dart';
import 'package:frontend/Pages/write_tip_page.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/Pages/chat_room.dart';
import 'package:frontend/Pages/friger.dart';
import 'package:frontend/Pages/mypage.dart';
import 'package:frontend/Pages/receipe_recommend.dart';
import 'package:frontend/Pages/share_ingredient.dart';
import 'package:frontend/widgets/receipe_element.dart';

class ShareReceipe extends StatefulWidget {
  final List<CameraDescription> cameras;

  const ShareReceipe({super.key, required this.cameras});

  @override
  _ShareReceipeState createState() => _ShareReceipeState();
}

class _ShareReceipeState extends State<ShareReceipe> {
  List<Map<String, dynamic>> receipes = [];

  @override
  void initState() {
    super.initState();
    fetchReceipes();
  }

  Future<void> fetchReceipes() async {
    final url = Uri.parse('http://172.17.114.116:22222/tips');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        // isShared를 랜덤하게 추가
        // final random = Random();
        receipes = data.map((item) {
          return {
            'id': item['id'],
            // 'isShared': random.nextBool(), // true 또는 false 랜덤하게 설정
            'title': item['title'],
            'pictures': item['pictures'],
            'locationDong': item['locationDong'],
            'like_count': item['like_count'],
            'comment_count': item['comment_count'],
            'scrap_count': item['scrap_count'],
          };
        }).toList();

        // print(receipes);

        setState(() {});
      } else {
        throw Exception('Failed to load receipes');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          title: const Text(
            '비냉 나눔터',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WriteTipPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  width: 10,
                )
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShareIngredient(cameras: widget.cameras),
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
                        "정보 나눔",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF449C4A),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: 1,
                    color: Color(0xFFe5e5e5),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: receipes.length,
                      itemBuilder: (context, index) {
                        final r = receipes[index];
                        return GestureDetector(
                          onTap: () {
                            // 터치 시 ReceipeDetailPage로 이동하면서 id를 전달
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ReceipeDetailPage(id: r['id']),
                              ),
                            );
                          },
                          child: ReceipeShareElement(
                            id: r['id'],
                            // isShared: r['isShared'],
                            title: r['title'],
                            imgPath: r['pictures'].isNotEmpty
                                ? r['pictures'][0]
                                : "",
                            locationDong: r['locationDong'],
                            like_count: r['like_count'],
                            comment_count: r['comment_count'],
                            scrap_count: r['scrap_count'],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  )
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
                                builder: (context) => ReceipeRecommend(
                                    cameras: super.widget.cameras),
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
                          onPressed: () => {},
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
                                builder: (context) =>
                                    Friger(cameras: super.widget.cameras),
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
                                    ChatRoom(cameras: super.widget.cameras),
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
                                builder: (context) =>
                                    MyPage(cameras: super.widget.cameras),
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

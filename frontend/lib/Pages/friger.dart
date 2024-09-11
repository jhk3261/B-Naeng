import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Pages/chat_room.dart';
import 'package:frontend/Pages/mypage.dart';
import 'package:frontend/Pages/receipe_recommend.dart';
import 'package:frontend/Pages/share_ingredient.dart';
import 'package:frontend/widgets/friger_food.dart';
import 'package:frontend/widgets/plus_btn.dart';

class Friger extends StatelessWidget {
  final List<CameraDescription> cameras;

  const Friger({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 75),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "홍길동",
                            style: TextStyle(
                                fontFamily: 'GmarketSansBold',
                                fontSize: 24,
                                color: Color(0xFF449C4A)),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "님의 냉장고",
                            style: TextStyle(
                              fontFamily: 'GmarketSansBold',
                              fontSize: 18,
                              color: Color(0xFF8EC96D),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.repeat_rounded,
                            color: Color(0xFFCBCBCB),
                            size: 18,
                          ),
                        ],
                      ),
                      Icon(
                        Icons.alarm,
                        color: Color(0xFF449C4A),
                        size: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      Text(
                        "전체보기",
                        style: TextStyle(
                          fontFamily: 'GmarketSans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF449C4A),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "육류",
                        style: TextStyle(
                          fontFamily: 'GmarketSans',
                          fontSize: 16,
                          color: Color(0xFFCBCBCB),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "소스",
                        style: TextStyle(
                          fontFamily: 'GmarketSans',
                          fontSize: 16,
                          color: Color(0xFFCBCBCB),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "유제품",
                        style: TextStyle(
                          fontFamily: 'GmarketSans',
                          fontSize: 16,
                          color: Color(0xFFCBCBCB),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "채소",
                        style: TextStyle(
                          fontFamily: 'GmarketSans',
                          fontSize: 16,
                          color: Color(0xFFCBCBCB),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Container(
                    alignment: Alignment.topLeft,
                    color: const Color(0xFFFAFAFA),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      child: Column(children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "육류",
                              style: TextStyle(
                                fontFamily: 'GmarketSansBold',
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(children: [
                                const Row(children: [
                                  FrigerFood(
                                    num: "2",
                                    day: 1,
                                    imagePath: 'assets/images/food_pork.png',
                                    food: '돼지고기 100g',
                                    bgColor: Color(0xFFFDF4F4),
                                    bdColor: Color(0xFFF28585),
                                    ftColor: Color(0xFFCE2A2A),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  FrigerFood(
                                    num: "2",
                                    day: 3,
                                    imagePath: 'assets/images/food_beef.png',
                                    food: '소고기 100g',
                                    bgColor: Color(0xFFF6FAF6),
                                    bdColor: Color(0xFFAED3B0),
                                    ftColor: Color(0xFF449C4A),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  FrigerFood(
                                    num: "2",
                                    day: 5,
                                    imagePath:
                                        'assets/images/food_chickenleg.png',
                                    food: '닭다리살',
                                    bgColor: Color(0xFFF6FAF6),
                                    bdColor: Color(0xFFAED3B0),
                                    ftColor: Color(0xFF449C4A),
                                  ),
                                ]),
                                const SizedBox(
                                  height: 24,
                                ),
                                Row(
                                  children: [
                                    const FrigerFood(
                                      num: "10",
                                      day: 10,
                                      imagePath: 'assets/images/food_bacon.png',
                                      food: '베이컨',
                                      bgColor: Color(0xFFF6FAF6),
                                      bdColor: Color(0xFFAED3B0),
                                      ftColor: Color(0xFF449C4A),
                                    ),
                                    const SizedBox(
                                      width: 44,
                                    ),
                                    PlusBtn(
                                        //cameras: cameras,
                                        ),
                                  ],
                                )
                              ]),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Divider(
                              color: Color(0xFFE5E5E5),
                              thickness: 1.0,
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "소스",
                              style: TextStyle(
                                fontFamily: 'GmarketSansBold',
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(children: [
                                const Row(children: [
                                  FrigerFood(
                                    num: "1",
                                    day: 5,
                                    imagePath: 'assets/images/food_source.png',
                                    food: '케찹',
                                    bgColor: Color(0xFFF6FAF6),
                                    bdColor: Color(0xFFAED3B0),
                                    ftColor: Color(0xFF449C4A),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  FrigerFood(
                                    num: "1",
                                    day: 10,
                                    imagePath: 'assets/images/food_source.png',
                                    food: '굴소스',
                                    bgColor: Color(0xFFF6FAF6),
                                    bdColor: Color(0xFFAED3B0),
                                    ftColor: Color(0xFF449C4A),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  FrigerFood(
                                    num: "1",
                                    day: 30,
                                    imagePath:
                                        'assets/images/food_tomatosource.png',
                                    food: '토마토소스',
                                    bgColor: Color(0xFFF6FAF6),
                                    bdColor: Color(0xFFAED3B0),
                                    ftColor: Color(0xFF449C4A),
                                  ),
                                ]),
                                const SizedBox(
                                  height: 24,
                                ),
                                Row(
                                  children: [
                                    const FrigerFood(
                                      num: "1",
                                      day: 60,
                                      imagePath:
                                          'assets/images/food_strjam.png',
                                      food: '딸기잼',
                                      bgColor: Color(0xFFF6FAF6),
                                      bdColor: Color(0xFFAED3B0),
                                      ftColor: Color(0xFF449C4A),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    const FrigerFood(
                                      num: "2",
                                      day: 365,
                                      imagePath:
                                          'assets/images/food_source.png',
                                      food: '마요네즈',
                                      bgColor: Color(0xFFF6FAF6),
                                      bdColor: Color(0xFFAED3B0),
                                      ftColor: Color(0xFF449C4A),
                                    ),
                                    const SizedBox(
                                      width: 44,
                                    ),
                                    PlusBtn(
                                        //cameras: cameras,
                                        ),
                                  ],
                                )
                              ]),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Divider(
                              color: Color(0xFFE5E5E5),
                              thickness: 1.0,
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "유제품",
                              style: TextStyle(
                                fontFamily: 'GmarketSansBold',
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(children: [
                                const Row(children: [
                                  FrigerFood(
                                    num: "3",
                                    day: 1,
                                    imagePath: 'assets/images/food_yogurt.png',
                                    food: '그릭요거트',
                                    bgColor: Color(0xFFFDF4F4),
                                    bdColor: Color(0xFFF28585),
                                    ftColor: Color(0xFFCE2A2A),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  FrigerFood(
                                    num: "1",
                                    day: 5,
                                    imagePath: 'assets/images/food_milk.png',
                                    food: '서울우유 500ml',
                                    bgColor: Color(0xFFF6FAF6),
                                    bdColor: Color(0xFFAED3B0),
                                    ftColor: Color(0xFF449C4A),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  FrigerFood(
                                    num: "2",
                                    day: 6,
                                    imagePath: 'assets/images/food_butter.png',
                                    food: '버터',
                                    bgColor: Color(0xFFF6FAF6),
                                    bdColor: Color(0xFFAED3B0),
                                    ftColor: Color(0xFF449C4A),
                                  ),
                                ]),
                                const SizedBox(
                                  height: 24,
                                ),
                                Row(
                                  children: [
                                    const FrigerFood(
                                      num: "5",
                                      day: 12,
                                      imagePath:
                                          'assets/images/food_cheese.png',
                                      food: '체다치즈',
                                      bgColor: Color(0xFFF6FAF6),
                                      bdColor: Color(0xFFAED3B0),
                                      ftColor: Color(0xFF449C4A),
                                    ),
                                    const SizedBox(
                                      width: 44,
                                    ),
                                    PlusBtn(
                                        // cameras: cameras,
                                        ),
                                  ],
                                )
                              ]),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Divider(
                              color: Color(0xFFE5E5E5),
                              thickness: 1.0,
                            )
                          ],
                        ),
                      ]),
                    ))
              ],
            ),
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
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ShareIngredient(cameras: cameras),
                          ),
                        );
                      },
                    ),
                    const Text("나눔터"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.kitchen, color: Color(0xFF8EC96D)),
                      onPressed: () {},
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
      ]),
    );
  }
}

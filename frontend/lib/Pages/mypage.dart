import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Pages/chat_room.dart';
import 'package:frontend/Pages/friger.dart';
import 'package:frontend/Pages/qr_scanner.dart';
import 'package:frontend/Pages/receipe_recommend.dart';
import 'package:frontend/Pages/share_ingredient.dart';

class MyPage extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyPage({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      cameras: cameras,
    );
  }
}

class ProfilePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const ProfilePage({super.key, required this.cameras});

  @override
  _ProfilePageState createState() => _ProfilePageState(cameras: cameras);
}

class _ProfilePageState extends State<ProfilePage> {
  final List<CameraDescription> cameras;

  _ProfilePageState({required this.cameras});
  bool isScrapExpanded = false;

  void toggleScrapSection() {
    setState(() {
      isScrapExpanded = !isScrapExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 프로필 섹션
                const SizedBox(height: 40),
                Container(
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
                        child: Image.asset(
                          'assets/images/profile.png',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                ),

                // 그린 포인트 섹션
                const SizedBox(height: 15),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1EFE2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '그린 포인트',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 5),
                      const Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '999',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF449C4A),
                              ),
                            ),
                            SizedBox(width: 3),
                            Text(
                              '점',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // 사용하기 클릭 시 다른 페이지로 이동 (임시)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UsePointsPage()),
                          );
                        },
                        child: const Text(
                          '사용하기',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color.fromARGB(255, 159, 159, 159),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 가족 구성원 및 냉장고 섹션
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.transparent,
                            child: Image.asset(
                              'assets/images/family.png',
                              width: 43,
                              height: 43,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 15),
                              const Text(
                                '가족 구성원',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'GmarketSansMedium',
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '4',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'GmarketSansBold',
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Text(
                                '명',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'GmarketSansMedium',
                                ),
                              ),
                              const SizedBox(width: 3),
                              Image.asset(
                                'assets/images/rightArrow.png',
                                width: 18,
                                height: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 90,
                      color: const Color.fromARGB(255, 173, 173, 173),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    // Fridge Information
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
                                '2',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'GmarketSansBold',
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Text(
                                '대',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'GmarketSansMedium',
                                ),
                              ),
                              const SizedBox(width: 3),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          QRScan(cameras: cameras),
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  'assets/images/rightArrow.png',
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1, // 가로선 두께
                  color: const Color.fromARGB(255, 173, 173, 173), // 가로선 색상
                  width: double.infinity, // 가로선의 폭
                ),

                // 스크랩 섹션
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: toggleScrapSection,
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1EFE2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              style: TextStyle(fontSize: 14),
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
                ),

                // 스크랩 아이템 리스트 (애니메이션 적용)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isScrapExpanded ? 300.0 : 0.0,
                  child: isScrapExpanded
                      ? Scrollbar(
                          thumbVisibility: true,
                          thickness: 4.0, // 스크롤 바 두께
                          radius: const Radius.circular(5), // 스크롤 바 둥글게
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
                        )
                      : Container(), // 스크랩 섹션이 닫혀 있을 때는 빈 컨테이너로 처리
                ),
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
                      icon: const Icon(Icons.person, color: Color(0xFF8EC96D)),
                      onPressed: () {},
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

// 사용하기 페이지 (임시)
class UsePointsPage extends StatelessWidget {
  const UsePointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용하기'),
      ),
      body: const Center(
        child: Text('대충 사용하기 페이지 어쩌궁... 피그마 만든 게 없던데 그냥 없앨까...'),
      ),
    );
  }
}

class ScrapItem extends StatelessWidget {
  final String image;
  final String title;
  final int likes;
  final int comments;
  final String date;

  const ScrapItem({
    super.key,
    required this.image,
    required this.title,
    required this.likes,
    required this.comments,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Row(
        children: [
          Image.asset(
            image,
            width: 100,
            height: 70,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis, // 텍스트 일정 길이 넘어가면 말줄임표 처리
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // 하트 아이콘을 heart.png로 교체
                    Image.asset(
                      'assets/images/heart.png',
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likes',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    // 코멘트 아이콘을 comment.png로 교체
                    Image.asset(
                      'assets/images/comment.png',
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$comments',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const Spacer(),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

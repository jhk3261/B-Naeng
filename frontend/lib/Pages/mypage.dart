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

// 사용하기 페이지
class UsePointsPage extends StatefulWidget {
  const UsePointsPage({super.key});

  @override
  _UsePointsPageState createState() => _UsePointsPageState();
}

class _UsePointsPageState extends State<UsePointsPage> {
  int _selectedAmount = 10000; // 초기값 설정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용하기'),
        backgroundColor: Colors.white,
        elevation: 0, // 그림자 제거
        centerTitle: true, // 제목을 가운데 정렬
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '보유 중인 그린 포인트',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '10000 gp',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50), // 녹색
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildRadioButton(10000, '10000원'),
                  _buildRadioButton(20000, '20000원'),
                  _buildRadioButton(30000, '30000원'),
                  _buildRadioButton(40000, '40000원'),
                  _buildRadioButton(50000, '50000원'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 변경하기 버튼 클릭 시 처리할 로직
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // 녹색
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  textStyle: const TextStyle(fontSize: 18),
                  minimumSize: const Size(double.infinity, 50), // 버튼 가로 채우기
                ),
                child: const Text('변경하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton(int value, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmount = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedAmount == value
                ? const Color(0xFF4CAF50)
                : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(
              _selectedAmount == value
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: _selectedAmount == value
                  ? const Color(0xFF4CAF50)
                  : Colors.grey,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                color: _selectedAmount == value
                    ? const Color(0xFF4CAF50)
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
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

  // 냉장고 팝업
  void showFridgeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            height: 300, // 필요에 따라 높이 조정 가능
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '냉장고 소유 목록',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // 다이얼로그 닫기
                      },
                      child: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text(
                          '현재 선택된 냉장고',
                          style: TextStyle(color: Colors.green),
                        ),
                        trailing: const Text(
                          '관리',
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          // 여기에서 필요한 로직 구현
                        },
                      ),
                      ListTile(
                        title: const Text('2번 냉장고'),
                        trailing: const Text(
                          '관리',
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          // 여기에서 필요한 로직 구현
                        },
                      ),
                      ListTile(
                        title: const Text('3번 냉장고'),
                        trailing: const Text(
                          '관리',
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          // 여기에서 필요한 로직 구현
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

                // 냉장고 섹션
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
                                  showFridgeDetails(
                                      context); // 화살표 아이콘을 클릭했을 때 다이얼로그를 표시
                                },
                                child: Image.asset(
                                  'assets/images/rightArrow.png',
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          )
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/Pages/mypage/fridge_popup.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
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
  int userId = 1;
  bool isScrapSectionOpen = false;
  List<ScrapItem> scrapItems = [];

  @override
  void initState() {
    super.initState();
    userProfileFuture = fetchUserProfile(userId);
    fetchScrapItems(userId).then((items) {
      setState(() {
        scrapItems = items;
      });
    }).catchError((error) {});
  }

  Future<UserProfile> fetchUserProfile(int userId) async {
    try {
      final url = Uri.parse('$apiUrl/load/userinfo?user_id=$userId');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        if (data.length < 2) {
          throw Exception('Invalid user profile data');
        }
        Map<String, dynamic> userJson =
            data[0] as Map<String, dynamic>; // user 정보
        int fridgeCount = data[1] as int; // 냉장고 개수

        return UserProfile.fromJson(userJson, fridgeCount);
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (error) {
      return UserProfile(
        id: userId,
        userId: userId,
        username: '기본 사용자',
        profileImageUrl: null,
        greenPoints: 0,
        fridgeCount: 0,
      );
    }
  }

  Future<List<ScrapItem>> fetchScrapItems(int userId) async {
    try {
      final response =
          await http.get(Uri.parse('$apiUrl/users/$userId/scraps'));

      if (response.statusCode == 200) {
        List<dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

        if (data.isEmpty) {
          return [];
        }
        return data
            .map((json) => ScrapItem.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load scrap items');
      }
    } catch (error) {
      return Future.error('스크랩 항목을 불러오는 데 오류가 발생했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<UserProfile>(
                future: userProfileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
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
                          buildScrapSection(context),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileSection(UserProfile profile) {
    return Column(
      children: [
        const SizedBox(height: 80),
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
            onPressed: () async {
              final usedPoints = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UsePointsPage(
                    userId: profile.userId,
                    onRefresh: () {
                      setState(() {
                        userProfileFuture = fetchUserProfile(profile.userId);
                      });
                    },
                  ),
                ),
              );

              if (usedPoints != null) {
                setState(() {
                  profile.greenPoints -= (usedPoints as num).toInt();
                  userProfileFuture = fetchUserProfile(profile.userId);
                });
              }
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

  void showFridgePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const FridgePopup();
      },
    );
  }

  Widget buildFridgeSection(UserProfile profile) {
    return GestureDetector(
      onTap: () => showFridgePopup(context),
      child: Container(
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
      ),
    );
  }

  Widget buildScrapSection(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isScrapSectionOpen = !isScrapSectionOpen;
            });
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE1EFE2),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/star.png',
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  '스크랩',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Icon(
                  isScrapSectionOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 24,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (isScrapSectionOpen) ...[
          FutureBuilder<List<ScrapItem>>(
            future: fetchScrapItems(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('스크랩 항목이 없습니다.'));
              } else {
                scrapItems = snapshot.data!;
                return scrapItems.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('스크랩 항목이 없습니다.'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: scrapItems.length,
                        itemBuilder: (context, index) {
                          final item = scrapItems[index];

                          String imageUrl = item.imageUrl != null
                              ? "$apiUrl/scrap_image?file_path=${item.imageUrl}"
                              : "assets/images/noimg.png";

                          return ListTile(
                            leading: SizedBox(
                              width: 80,
                              height: 60,
                              child: item.imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/noimg.png',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      'assets/images/noimg.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            title: Text(item.title),
                            subtitle: Row(
                              children: [
                                Image.asset(
                                  'assets/images/heart.png',
                                  width: 15,
                                  height: 15,
                                ),
                                const SizedBox(width: 5),
                                Text('${item.likeCount}'),
                                const SizedBox(width: 10),
                                Image.asset(
                                  'assets/images/comment.png',
                                  width: 15,
                                  height: 15,
                                ),
                                const SizedBox(width: 5),
                                Text('${item.commentCount}'),
                                const SizedBox(width: 10),
                                Image.asset(
                                  'assets/images/star.png',
                                  width: 15,
                                  height: 15,
                                ),
                                const SizedBox(width: 5),
                                Text('${item.scrapCount}'),
                              ],
                            ),
                          );
                        },
                      );
              }
            },
          ),
        ],
      ],
    );
  }
}

class UserProfile {
  final int id;
  final int userId;
  final String? username;
  final String? profileImageUrl;
  int greenPoints;
  final int fridgeCount;

  UserProfile({
    required this.id,
    required this.userId,
    this.username,
    this.profileImageUrl,
    required this.greenPoints,
    required this.fridgeCount,
  });

  // fridgeCount를 추가로 받는 생성자
  factory UserProfile.fromJson(Map<String, dynamic> json, int fridgeCount) {
    return UserProfile(
      id: json['id'] != null ? json['id'] as int : 0,
      userId: json['user_id'] != null ? json['user_id'] as int : 0,
      username: json['username'] as String? ?? '기본 사용자',
      profileImageUrl: json['profile_image_url'] as String?,
      greenPoints:
          json['green_points'] != null ? json['green_points'] as int : 0,
      fridgeCount: fridgeCount,
    );
  }
}

class ScrapItem {
  final int id;
  final String title;
  final String? imageUrl; // nullable String
  final int likeCount;
  final int commentCount;
  final int scrapCount;
  final String createdAt;

  ScrapItem({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.scrapCount,
    required this.createdAt,
  });

  factory ScrapItem.fromJson(Map<String, dynamic> json) {
    String? imageUrl =
        (json['pictures'] != null && (json['pictures'] as List).isNotEmpty)
            ? '${json['pictures'][0].replaceAll("\\", "/")}'
            : null;

    return ScrapItem(
      id: json['id'] != null ? json['id'] as int : 0,
      title: json['title'] as String? ?? '제목 없음',
      imageUrl: imageUrl,
      likeCount: json['like_count'] != null ? json['like_count'] as int : 0,
      commentCount:
          json['comment_count'] != null ? json['comment_count'] as int : 0,
      scrapCount: json['scrap_count'] != null ? json['scrap_count'] as int : 0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

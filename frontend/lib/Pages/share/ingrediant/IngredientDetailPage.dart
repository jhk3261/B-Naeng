import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 패키지 추가

// Ingredient 클래스 정의
class Ingredient {
  final int id;
  final String title;
  final String contents;
  final bool isShared;
  final List<String> pictures;
  final int likeCount;
  final int commentCount;
  final int scrapCount;
  final bool isLiked;
  final bool isScrapped;
  final List<String> comments;
  final String locationDong;

  Ingredient({
    required this.id,
    required this.title,
    required this.contents,
    required this.isShared,
    required this.pictures,
    required this.likeCount,
    required this.commentCount,
    required this.scrapCount,
    required this.isLiked,
    required this.isScrapped,
    required this.comments,
    required this.locationDong,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    var picturesFromJson = json['pictures'] as List<dynamic>;
    var commentsFromJson = json['comments'] as List<dynamic>;

    List<String> picturesList =
        picturesFromJson.map((i) => i as String).toList();
    List<String> commentsList =
        commentsFromJson.map((i) => i as String).toList();

    return Ingredient(
      id: json['id'],
      title: json['title'],
      contents: json['contents'],
      isShared: json['is_shared'],
      pictures: picturesList,
      likeCount: json['like_count'],
      commentCount: json['comment_count'],
      scrapCount: json['scrap_count'],
      isLiked: json['is_liked'],
      isScrapped: json['is_scrapped'],
      comments: commentsList,
      locationDong: json['locationDong'] ?? "", // null 처리
    );
  }
}

class IngredientDetailPage extends StatefulWidget {
  final int id;

  const IngredientDetailPage({super.key, required this.id});

  @override
  _IngredientDetailPageState createState() => _IngredientDetailPageState();
}

class _IngredientDetailPageState extends State<IngredientDetailPage> {
  bool isLiked = false;
  bool isScrapped = false;
  final int userId = 0; // 현재 유저 아이디(0으로 고정)

  @override
  void initState() {
    super.initState();
    _fetchIngredientData(); // 페이지 로드 시 데이터 가져오기
    _loadLikeStatus(); // 좋아요 상태 로드
  }

  // 좋아요 상태를 로드하는 메서드
  Future<void> _loadLikeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLiked =
          prefs.getBool('liked_${widget.id}') ?? false; // 로컬 스토리지에서 좋아요 상태 불러오기
    });
  }

  Future<void> _toggleLike() async {
    // isLiked가 true일 때만 서버에 요청
    if (!isLiked) {
      final url =
          Uri.parse('http://127.0.0.1:8000/ingredients/${widget.id}/likes');
      try {
        await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"user_id": userId}),
        );
        setState(() {
          isLiked = true; // 좋아요 상태 업데이트
        });
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('liked_${widget.id}', true); // 로컬 스토리지에 좋아요 상태 저장
      } catch (e) {
        print('Error liking post: $e');
      }
    }
  }

  Future<void> _toggleScrap() async {
    setState(() {
      isScrapped = !isScrapped;
    });

    final url =
        Uri.parse('http://127.0.0.1:8000/ingredients/${widget.id}/scraps');
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"user_id": userId}),
      );
    } catch (e) {
      print('Error scrapping post: $e');
      setState(() {
        isScrapped = !isScrapped;
      });
    }
  }

  Future<void> _sendComment(String content) async {
    final url =
        Uri.parse('http://127.0.0.1:8000/ingredients/${widget.id}/comments');
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"user_id": userId, "content": content}),
      );
      setState(() {}); // 댓글 추가 후 화면 갱신
    } catch (e) {
      print('Error sending comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("재료 나눔터"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                FutureBuilder<Ingredient>(
                  future: _fetchIngredient(widget.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final ingredient = snapshot.data!;
                      return Column(
                        children: [
                          _buildPost(ingredient),
                          const Divider(),
                          _buildCommentSection(ingredient.comments),
                        ],
                      );
                    } else {
                      return const Center(child: Text('No data available'));
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildCommentInputBar(context),
        ],
      ),
    );
  }

  Future<Ingredient> _fetchIngredient(int id) async {
    final url = Uri.parse('http://127.0.0.1:8000/ingredients/$id');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            jsonDecode(utf8.decode(response.bodyBytes));
        return Ingredient.fromJson(jsonData); // Ingredient 객체 반환
      } else {
        throw Exception('Failed to load ingredient');
      }
    } catch (e) {
      print('Error fetching data: $e');
      rethrow;
    }
  }

  // 이미지를 불러오는 메서드
  Future<List<String>> _fetchImages(List<String> imagePaths) async {
    List<String> fullUrls = [];
    for (String path in imagePaths) {
      final fullUrl = 'http://127.0.0.1:8000/ingredient_image?file_path=.$path';
      fullUrls.add(fullUrl);
    }
    return fullUrls; // URL 목록 반환
  }

  Widget _buildPost(Ingredient ingredient) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ingredient.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            ingredient.contents,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w100),
          ),
          const SizedBox(height: 16),

          // 이미지 목록 표시
          if (ingredient.pictures.isNotEmpty)
            FutureBuilder<List<String>>(
              future: _fetchImages(ingredient.pictures), // 이미지 URL을 가져옴
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final imageUrls = snapshot.data!;
                  print(imageUrls);
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.network(
                          imageUrls[index],
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            return const Text('이미지를 불러오는 데 실패했습니다.');
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No images available'));
                }
              },
            ),
          const SizedBox(height: 16),

          // 댓글 개수와 좋아요/스크랩 정렬
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 댓글 개수는 좌측 정렬
              Text(
                '댓글 ${ingredient.commentCount}개',
                style: const TextStyle(fontSize: 16),
              ),

              // 좋아요와 스크랩은 우측 정렬
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.green : null,
                    ),
                    onPressed: _toggleLike, // 좋아요 토글
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection(List<String> comments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 10.0), // 좌우 여백 추가
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 프로필 이미지 추가
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(
                            'assets/images/profile.png'), // 기본 유저 이미지 경로
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(comments[index]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // 댓글 간 간격
                  const Divider(), // 댓글 구분선
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentInputBar(BuildContext context) {
    final TextEditingController commentController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "댓글을 입력하세요.",
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _sendComment(commentController.text);
              commentController.clear(); // 댓글 입력 후 입력란 비우기
            },
          ),
        ],
      ),
    );
  }

  Future<void> _fetchIngredientData() async {
    try {
      final ingredient = await _fetchIngredient(widget.id);
      setState(() {
        // fetched ingredient data can be set to state if needed
      });
    } catch (e) {
      print('Error fetching ingredient data: $e');
    }
  }
}

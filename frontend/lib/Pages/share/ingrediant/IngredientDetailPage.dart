import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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
    _checkInitialStates();
  }

  // 좋아요와 스크랩 여부 확인
  Future<void> _checkInitialStates() async {
    final ingredient = await _fetchIngredient(widget.id);
    setState(() {
      isLiked = ingredient['like_count'] > 0;
      isScrapped = ingredient['scrap_count'] > 0;
    });
  }

  // 좋아요 요청
  Future<void> _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
    });

    final url = Uri.parse('http://127.0.0.1:8000/ingredients/${widget.id}/likes');
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"user_id": userId}),
      );
    } catch (e) {
      print('Error liking post: $e');
      // 오류 시 상태 롤백
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  // 스크랩 요청
  Future<void> _toggleScrap() async {
    setState(() {
      isScrapped = !isScrapped;
    });

    final url = Uri.parse('http://127.0.0.1:8000/ingredients/${widget.id}/scraps');
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"user_id": userId}),
      );
    } catch (e) {
      print('Error scrapping post: $e');
      // 오류 시 상태 롤백
      setState(() {
        isScrapped = !isScrapped;
      });
    }
  }

  // 댓글 요청
  Future<void> _sendComment(String content) async {
    final url = Uri.parse('http://127.0.0.1:8000/ingredients/${widget.id}/comments');
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
        title: const Text("재료 상세 정보"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                FutureBuilder<Map<String, dynamic>>(
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
                          _buildCommentSection(ingredient['comments']),
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

  // HTTP 요청을 통해 재료 데이터를 가져오는 함수
  Future<Map<String, dynamic>> _fetchIngredient(int id) async {
    final url = Uri.parse('http://127.0.0.1:8000/ingredients/$id');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load ingredient');
      }
    } catch (e) {
      print('Error fetching data: $e');
      rethrow;
    }
  }

  // 재료 내용을 출력하는 위젯
  Widget _buildPost(Map<String, dynamic> ingredient) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ingredient['name'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            ingredient['description'],
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w100),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.chat_bubble, color: Color(0xff8EC96D)),
                  const SizedBox(width: 5),
                  Text(
                    "${ingredient["comments"].length}",
                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_rounded,
                      color: isLiked ? const Color(0xff449C4A) : const Color(0xffDFDFDF),
                    ),
                    onPressed: _toggleLike,
                  ),
                  IconButton(
                    icon: Icon(
                      isScrapped ? Icons.star : Icons.star_rounded,
                      color: isScrapped ? const Color(0xff449C4A) : const Color(0xffDFDFDF),
                    ),
                    onPressed: _toggleScrap,
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  // 서버에서 받아온 댓글 데이터를 기반으로 댓글 섹션을 동적으로 생성
  Widget _buildCommentSection(List<dynamic> comments) {
    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('댓글이 없습니다.'),
      );
    }

    return Column(
      children: comments.map((comment) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: Text((comment['user_id']).toString()),
          ),
          title: Text(comment['content']),
          subtitle: Text(comment['created_at']),
        );
      }).toList(),
    );
  }

  // 하단 댓글 입력창 UI
  Widget _buildCommentInputBar(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 25, top: 5, bottom: 30),
        color: const Color(0xff8EC96D),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: '댓글을 입력하세요',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _sendComment(controller.text);
                  controller.clear(); // 입력 필드 초기화
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

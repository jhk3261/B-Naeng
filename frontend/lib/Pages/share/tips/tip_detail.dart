import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceipeDetailPage extends StatefulWidget {
  final int id;

  const ReceipeDetailPage({super.key, required this.id});

  @override
  _ReceipeDetailPageState createState() => _ReceipeDetailPageState();
}

class _ReceipeDetailPageState extends State<ReceipeDetailPage> {
  bool isLiked = false;
  bool isScrapped = false;
  final int userId = 1; // 현재 유저 아이디(0으로 고정)

  @override
  void initState() {
    super.initState();
    _checkInitialStates();
  }

  // 좋아요와 스크랩 여부 확인
  Future<void> _checkInitialStates() async {
    final tip = await _fetchTip(widget.id);
    setState(() {
      // 좋아요 여부 확인 (user_id가 0인 경우)
      isLiked = tip['like_count'] > 0;
      // 스크랩 여부 확인 (현재는 user_id 0으로 고정)
      isScrapped = tip['scrap_count'] > 0;
    });
  }

  // 좋아요 요청
  Future<void> _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
    });

    final url = Uri.parse('http://127.0.0.1:8000/tips/${widget.id}/likes');
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          {"user_id": userId},
        ),
      );
    } catch (e) {
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

    final url = Uri.parse('http://127.0.0.1:8000/tips/${widget.id}/scraps');
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          {"user_id": userId},
        ),
      );
    } catch (e) {
      // 오류 시 상태 롤백
      setState(() {
        isScrapped = !isScrapped;
      });
    }
  }

  // 댓글 요청
  Future<void> _sendComment(String content) async {
    final url = Uri.parse('http://127.0.0.1:8000/tips/${widget.id}/comments');
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"user_id": userId, "content": content}),
      );
      setState(() {}); // 댓글 추가 후 화면 갱신
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.white,
        shadowColor: const Color(0xFF232323),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "정보 나눔터",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                children: [
                  FutureBuilder<Map<String, dynamic>>(
                    future: _fetchTip(widget.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final tip = snapshot.data!;
                        return Column(
                          children: [
                            _buildPost(tip, tip["username"]),
                            const Divider(),
                            _buildCommentSection(tip['comments']),
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
          ),
          const Divider(height: 1),
          _buildCommentInputBar(context),
        ],
      ),
    );
  }

  // HTTP 요청을 통해 게시글 데이터를 가져오는 함수
  Future<Map<String, dynamic>> _fetchTip(int id) async {
    final url = Uri.parse('http://127.0.0.1:8000/tips/$id');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load tip');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 게시글 내용을 출력하는 위젯
  Widget _buildPost(Map<String, dynamic> tip, String username) {
    String category =
        tip["category"] == 0 ? "레시피" : (tip["category"] == 1 ? "관리" : "특가");

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xff8db600),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              category,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            tip['title'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 1.5, height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/images/profile.png",
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        tip['locationDong'],
                        style: const TextStyle(color: Color(0xff838383)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 1.5, height: 1),
          const SizedBox(height: 20),
          Text(
            tip['contents'],
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w100,
            ),
          ),
          const SizedBox(height: 16),
          if (tip['pictures'] != null && tip['pictures'].isNotEmpty)
            ListView.builder(
              shrinkWrap: true, // 부모 크기에 맞춰줌
              physics:
                  const NeverScrollableScrollPhysics(), // ListView가 스크롤 되지 않도록 설정
              itemCount: tip['pictures'].length,
              itemBuilder: (context, index) {
                final pictureUrl = tip['pictures'][index];

                final fullUrl =
                    "http://127.0.0.1:8000/tip_image?file_path=$pictureUrl";

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.network(fullUrl),
                );
              },
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    size: 28,
                    Icons.chat_bubble,
                    color: Color(0xff8EC96D),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "${tip["comments"].length}",
                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      size: 28,
                      isLiked ? Icons.favorite : Icons.favorite_rounded,
                      color: isLiked
                          ? const Color(0xff449C4A)
                          : const Color(0xffDFDFDF),
                    ),
                    onPressed: _toggleLike,
                  ),
                  IconButton(
                    icon: Icon(
                      size: 32,
                      isScrapped ? Icons.star : Icons.star_rounded,
                      color: isScrapped
                          ? const Color(0xff449C4A)
                          : const Color(0xffDFDFDF),
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
          subtitle: Text(
            DateFormat('yyyy년 MM월 dd일 HH:mm')
                .format(DateTime.parse(comment['created_at'])),
          ),
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
        padding: const EdgeInsets.only(left: 32, right: 16, top: 5, bottom: 30),
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

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ReceipeDetailPage extends StatelessWidget {
  final int id;

  const ReceipeDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text("정보 나눔터"),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                FutureBuilder<Map<String, dynamic>>(
                  future: _fetchTip(id), // Future<Map<String, dynamic>>를 반환
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      // 데이터가 성공적으로 로드되었을 때
                      return _buildPost(snapshot.data!);
                    } else {
                      return const Center(child: Text('No data available'));
                    }
                  },
                ),
                const Divider(),
                _buildCommentSection(),
              ],
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
    final url = Uri.parse('http://192.168.0.8:22222/tips/$id');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> item =
            jsonDecode(utf8.decode(response.bodyBytes));

        // 데이터를 받아온 후, 필요한 필드만 선택해서 반환
        return {
          'id': item['id'],
          'title': item['title'],
          'contents': item['contents'],
          'category': item['category'],
          'pictures': item['pictures'],
          'locationDong': item['locationDong'],
          'like_count': item['like_count'],
          'comments': item['comments'],
          'scrap_count': item['scrap_count'],
        };
      } else {
        throw Exception('Failed to load tip');
      }
    } catch (e) {
      print('Error fetching data: $e');
      rethrow; // 오류 발생 시, 해당 오류를 throw
    }
  }

  // 게시글 내용을 출력하는 위젯
  Widget _buildPost(Map<String, dynamic> tip) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tip['title'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 1.5, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/images/rice.jpeg",
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "신지아지랑이",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(tip['locationDong']),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 1.5, height: 1),
          const SizedBox(height: 10),
          Text(tip['contents']), // 서버에서 가져온 내용 사용
          const SizedBox(height: 16),
          tip['pictures'] != null && tip['pictures'].isNotEmpty
              ? Image.asset(tip['pictures'][0]) // 첫 번째 이미지를 표시
              : const Placeholder(
                  fallbackHeight: 200, fallbackWidth: double.infinity),
          const SizedBox(height: 16),
          Row(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.chat_bubble,
                    color: Color(0xff8EC96D),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text("${tip["comments"].length}"),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.star_border),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 댓글 목록 UI
  Widget _buildCommentSection() {
    return Column(
      children: List.generate(3, (index) {
        return const ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: Text('신'),
          ),
          title: Text('완전 설탕팁이네요 ㅎㅎㅎ 감사합니다.'),
          subtitle: Text('2024.09.10'),
        );
      }),
    );
  }

  // 하단 댓글 입력창 UI
  Widget _buildCommentInputBar(BuildContext context) {
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
                decoration: const InputDecoration(
                  hintText: '댓글을 입력하세요',
                  border: InputBorder.none,
                ),
                onTap: () {
                  // 키보드와 함께 창이 올라오는 효과 처리
                  FocusScope.of(context).requestFocus(FocusNode());
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

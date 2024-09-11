import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IngredientDetailPage extends StatefulWidget {
  final int ingredientId; // 식재료 ID
  final String title;
  final String imageUrl;
  final String description;

  IngredientDetailPage({
    required this.ingredientId,
    required this.title,
    required this.imageUrl,
    required this.description,
  });

  @override
  _IngredientDetailPageState createState() => _IngredientDetailPageState();
}

class _IngredientDetailPageState extends State<IngredientDetailPage> {
  int _likeCount = 0;
  bool _isLiked = false;
  int _commentCount = 0;
  int _scrapCount = 0;
  bool _isScrapped = false;
  final TextEditingController _commentController = TextEditingController();
  List<String> _comments = []; // 댓글 목록

  @override
  void initState() {
    super.initState();
  }

  // 좋아요 추가/제거 API 호출
  Future<void> _toggleLike() async {
    try {
      final response = await http.post(
        Uri.parse('http://your-api-url.com/ingredients/${widget.ingredientId}/likes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': 1, // 예시
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          if (_isLiked) {
            _likeCount--;
          } else {
            _likeCount++;
          }
          _isLiked = !_isLiked;
        });
        print(_isLiked ? '좋아요 추가됨' : '좋아요 취소됨');
      } else {
        print('좋아요 처리 실패');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  // 댓글 추가 API 호출
  Future<void> _addComment() async {
    final content = _commentController.text;
    if (content.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('http://your-api-url.com/ingredients/${widget.ingredientId}/comments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': 1,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _comments.add(content); // 댓글을 목록에 추가
          _commentCount++; // 댓글 개수 증가
        });
        _commentController.clear();
        print('댓글 추가됨: $content'); // 댓글 내용 터미널에 출력
      } else {
        print('댓글 추가 실패');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  // 스크랩 추가/제거 API 호출
  Future<void> _toggleScrap() async {
    try {
      final response = await http.post(
        Uri.parse('http://your-api-url.com/ingredients/${widget.ingredientId}/scraps'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': 1,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          if (_isScrapped) {
            _scrapCount--;
          } else {
            _scrapCount++;
          }
          _isScrapped = !_isScrapped;
        });
        print(_isScrapped ? '스크랩 추가됨' : '스크랩 취소됨');
      } else {
        print('스크랩 처리 실패');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  // 글 삭제 API 호출
  Future<void> _deletePost() async {
    try {
      final response = await http.delete(
        Uri.parse('http://your-api-url.com/ingredients/${widget.ingredientId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('삭제되었습니다.'); // 삭제 성공 시 터미널 출력
        Navigator.pop(context); // 페이지 닫기
      } else {
        print('글 삭제 실패');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // 삭제 확인 대화상자
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('삭제 확인'),
                    content: Text('이 글을 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        child: Text('취소'),
                        onPressed: () {
                          Navigator.of(context).pop(); // 대화상자 닫기
                        },
                      ),
                      TextButton(
                        child: Text('삭제'),
                        onPressed: () {
                          Navigator.of(context).pop(); // 대화상자 닫기
                          _deletePost(); // 글 삭제 호출
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(widget.imageUrl, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/images/profile.png'),
                        radius: 24,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('신지아', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('가좌동'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(widget.description),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: '댓글을 작성하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: _addComment,
                    child: Text('댓글 추가'),
                  ),
                  SizedBox(height: 16.0),
                  // 댓글 목록 표시
                  Text('댓글 목록', style: TextStyle(fontWeight: FontWeight.bold)),
                  ..._comments.map((comment) => ListTile(title: Text(comment))).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.green,
              ),
              onPressed: _toggleLike,
            ),
            Text(_isLiked ? "$_likeCount" : "$_likeCount"),
            IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: Colors.green),
              onPressed: () {},
            ),
            Text("$_commentCount"),
            IconButton(
              icon: Icon(
                _isScrapped ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.green,
              ),
              onPressed: _toggleScrap,
            ),
            Text(_isScrapped ? "$_scrapCount" : "$_scrapCount"),
          ],
        ),
      ),
    );
  }
}

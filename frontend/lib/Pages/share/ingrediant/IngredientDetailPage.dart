import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiUrl = 'http://127.0.0.1:8000';

class IngredientDetailPage extends StatefulWidget {
  final int ingredientId;
  final String title;
  final String description;
  final List<String> images;

  const IngredientDetailPage({
    super.key,
    required this.ingredientId,
    required this.title,
    required this.description,
    required this.images,
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
  final List<String> _comments = [];
  
  // 실제 유저 ID로 변경 필요
  final int _userId = 2024;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  String getImageUrl(String imagePath) {
    return '$apiUrl/assets/uploads/$imagePath';
  }

  Future<void> _fetchInitialData() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/ingredients/${widget.ingredientId}?user_id=$_userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ingredientResponse = IngredientResponse.fromJson(data);
        setState(() {
          _likeCount = ingredientResponse.likeCount ?? 0;
          _commentCount = ingredientResponse.commentCount ?? 0;
          _scrapCount = ingredientResponse.scrapCount ?? 0;
          _isLiked = ingredientResponse.isLiked ?? false;
          _isScrapped = ingredientResponse.isScrapped ?? false;
          _comments.addAll(ingredientResponse.comments ?? []);
        });
      } else {
        _showErrorSnackBar('초기 데이터 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('오류 발생: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleLike() async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/ingredients/${widget.ingredientId}/likes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': _userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
      } else {
        _showErrorSnackBar('좋아요 처리 실패: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('오류 발생: $e');
    }
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      _showErrorSnackBar('댓글 내용을 입력하세요.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/ingredients/${widget.ingredientId}/comments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': _userId, 'content': content}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _comments.add(content);
          _commentCount++;
          _commentController.clear();
        });
      } else {
        _showErrorSnackBar('댓글 추가 실패: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('오류 발생: $e');
    }
  }

  Future<void> _toggleScrap() async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/ingredients/${widget.ingredientId}/scraps'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': _userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isScrapped = !_isScrapped;
          _scrapCount += _isScrapped ? 1 : -1;
        });
      } else {
        _showErrorSnackBar('스크랩 처리 실패: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('오류 발생: $e');
    }
  }

  Future<void> _deletePost() async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/ingredients/${widget.ingredientId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        _showErrorSnackBar('글 삭제 실패: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('삭제 확인'),
                    content: const Text('이 글을 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        child: const Text('취소'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: const Text('삭제'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _deletePost();
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
            widget.images.isNotEmpty
                ? Image.network(
                    getImageUrl(widget.images[0]),
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Image.asset('assets/images/default.jpg');
                    },
                  )
                : Image.asset('assets/images/default.jpg'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
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
                  const SizedBox(height: 16.0),
                  Text(widget.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  Text(widget.description),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: '댓글을 작성하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: _addComment,
                    child: const Text('댓글 추가'),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('댓글 목록', style: TextStyle(fontWeight: FontWeight.bold)),
                  ..._comments.map((comment) => ListTile(title: Text(comment))),
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
            Text('$_likeCount'),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.green),
              onPressed: () {},
            ),
            Text('$_commentCount'),
            IconButton(
              icon: Icon(
                _isScrapped ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.green,
              ),
              onPressed: _toggleScrap,
            ),
            Text('$_scrapCount'),
          ],
        ),
      ),
    );
  }
}

class IngredientResponse {
  final int? likeCount;
  final int? commentCount;
  final int? scrapCount;
  final bool? isLiked;
  final bool? isScrapped;
  final List<String>? comments;

  IngredientResponse({
    this.likeCount,
    this.commentCount,
    this.scrapCount,
    this.isLiked,
    this.isScrapped,
    this.comments,
  });

  factory IngredientResponse.fromJson(Map<String, dynamic> json) {
    return IngredientResponse(
      likeCount: json['like_count'] as int?,
      commentCount: json['comment_count'] as int?,
      scrapCount: json['scrap_count'] as int?,
      isLiked: json['is_liked'] as bool?,
      isScrapped: json['is_scrapped'] as bool?,
      comments: List<String>.from(json['comments']?.map((x) => x as String) ?? []),
    );
  }
}

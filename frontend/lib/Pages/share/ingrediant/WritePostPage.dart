import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WritePostPage extends StatefulWidget {
  @override
  _WritePostPageState createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _imageUrl;
  bool _isShared = false;

  // 이미지 선택 함수 (추가 구현 필요)
  void _pickImage() {
    // TODO: 이미지 선택 구현
  }

  // 글 작성 API 호출
  Future<void> _submitPost() async {
    final String title = _titleController.text;
    final String content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      print("제목과 내용을 입력하세요.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://your-api-url.com/ingredients/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': 1,
          'title': title,
          'contents': content,
          'image_url': _imageUrl,
          'is_shared': _isShared,
        }),
      );

      if (response.statusCode == 200) {
        print('글이 성공적으로 작성되었습니다.');
        print('제목: $title');
        print('내용: $content');
        
        if (_isShared) {
          print('나눔 완료된 글입니다.');
        }

        Navigator.pop(context);
      } else {
        print('글 작성에 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('글 쓰기'),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.green),
            onPressed: _submitPost,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: '제목'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(hintText: '내용을 입력해 주세요.'),
              maxLines: 10,
            ),
            SwitchListTile(
              title: Text("공유 여부"),
              value: _isShared,
              onChanged: (bool value) {
                setState(() {
                  _isShared = value;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: IconButton(
          icon: Icon(Icons.camera_alt, color: Colors.green),
          onPressed: _pickImage,
        ),
      ),
    );
  }
}

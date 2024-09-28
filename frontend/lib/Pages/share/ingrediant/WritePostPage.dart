import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'share_ingredient.dart'; // 나눔 페이지

class WritePostPage extends StatefulWidget {
  final VoidCallback after_write;
  const WritePostPage({super.key, required this.after_write});

  @override
  _WritePostPageState createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _imageFile; // 이미지 파일 변수
  bool _isShared = false;

  // 이미지 선택 함수 (image_picker 패키지 사용)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // 선택한 이미지 파일 경로 저장
      });
    }
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
      // 이미지 URL이 없다면 기본 이미지로 설정
      String? imageUrl = _imageFile?.path ?? 'assets/images/profile.jpg';

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/ingredients/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': 2024, // 실제 유저 ID로 교체 필요
          'title': title,
          'contents': content,
          'image_url': imageUrl,
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

        widget.after_write();
        // 글 작성 후 나눔 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ShareIngredient(cameras: []),
          ),
        );
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
        title: const Text('글 쓰기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: _submitPost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: '제목'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: '내용을 입력해 주세요.'),
              maxLines: 10,
            ),
            const SizedBox(height: 16.0),
            SwitchListTile(
              title: const Text("공유 여부"),
              value: _isShared,
              onChanged: (bool value) {
                setState(() {
                  _isShared = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            _imageFile != null
                ? Image.file(_imageFile!) // 선택된 이미지 보여주기
                : const Text("이미지가 선택되지 않았습니다."),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: IconButton(
          icon: const Icon(Icons.camera_alt, color: Colors.green),
          onPressed: _pickImage,
        ),
      ),
    );
  }
}

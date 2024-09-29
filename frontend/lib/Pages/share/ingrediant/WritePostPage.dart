import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

const String apiUrl = 'http://127.0.0.1:8000';

class WritePostPage extends StatefulWidget {
  const WritePostPage({super.key});

  @override
  _WritePostPageState createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _locationDongController = TextEditingController();
  List<File> _pictures = [];
  bool _isShared = false;
  final int userId = 1;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    setState(() {
      _pictures = pickedFiles
          .map((pickedFile) => File(pickedFile.path))
          .toList(); // 선택한 이미지 파일 리스트 저장
    });
  }

  // 글 작성 API 호출
  Future<void> _submitPost() async {
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();
    final String locationDong = _locationDongController.text.trim();

    if (title.isEmpty || content.isEmpty || locationDong.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목, 내용, 지역을 입력하세요.')),
      );
      return;
    }

    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$apiUrl/ingredients/'));

      request.fields['user_id'] = userId.toString();
      request.fields['title'] = title;
      request.fields['contents'] = content;
      request.fields['is_shared'] = _isShared ? 'true' : 'false';
      request.fields['locationDong'] = locationDong;

      // 이미지 파일 추가 (선택사항)
      for (var file in _pictures) {
        request.files
            .add(await http.MultipartFile.fromPath('pictures', file.path));
      }

      // 요청 데이터 확인을 위해 출력

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // UI 상태 갱신
        setState(() {
          // 필요 시 입력 필드 및 상태 초기화
          _titleController.clear();
          _contentController.clear();
          _locationDongController.clear();
          _pictures.clear();
          _isShared = false;
        });

        // 글 작성 후 이전 화면으로 이동
        Navigator.pop(context);
      } else {
        String errorMessage = '글 작성에 실패했습니다.';
        try {
          final responseBody = jsonDecode(response.body);
          if (responseBody['detail'] != null) {
            errorMessage = responseBody['detail']
                .map((detail) => detail['msg'])
                .join(', ');
          }
        } catch (e) {
          // JSON 디코딩 실패 시 기본 메시지 유지
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF232323),
        title: const Text('글 쓰기'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: _submitPost,
              child: const Text(
                '올리기',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            // 스크롤 가능하도록 변경
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xFF449C4A),
                            width: 2.0), // 포커스 시 테두리 색상
                      ),
                      focusColor: Color(0xFF449C4A),
                      hintText: '제목',
                      hintStyle: TextStyle(
                        color: Color(0xffB7B7B7),
                      )),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xFF449C4A),
                            width: 2.0), // 포커스 시 테두리 색상
                      ),
                      hintText: '내용을 입력해 주세요.',
                      hintStyle: TextStyle(
                        color: Color(0xffB7B7B7),
                      ),
                      focusColor: Color(0xFF449C4A),
                      hoverColor: Color(0xFF449C4A)),
                  maxLines: 10,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _locationDongController,
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF449C4A), width: 2.0), // 포커스 시 테두리 색상
                    ),
                    hintText: '지역(동)을 입력해 주세요.',
                    hintStyle: TextStyle(
                      color: Color(0xffB7B7B7),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                SwitchListTile(
                  activeTrackColor: const Color(0xFF449C4A),
                  inactiveTrackColor: const Color.fromARGB(255, 229, 229, 229),
                  selectedTileColor: Colors.white,
                  title: const Text("공유 여부"),
                  value: _isShared,
                  onChanged: (bool value) {
                    setState(() {
                      _isShared = value;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                // 선택된 이미지 리스트 보여주기
                _pictures.isNotEmpty
                    ? Column(
                        children: _pictures
                            .map((file) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Image.file(file),
                                ))
                            .toList(),
                      )
                    : const Text("이미지가 선택되지 않았습니다."),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 1,
        shadowColor: const Color(0xffd2d2d2),
        color: const Color(0xFFF6FAF6),
        child: IconButton(
          iconSize: 36,
          icon: const Icon(Icons.camera_alt, color: Colors.green),
          onPressed: _pickImage,
        ),
      ),
    );
  }
}

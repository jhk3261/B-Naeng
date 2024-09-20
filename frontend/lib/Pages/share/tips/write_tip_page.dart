import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class WriteTipPage extends StatefulWidget {
  const WriteTipPage({super.key});

  @override
  _WriteTipPageState createState() => _WriteTipPageState();
}

class _WriteTipPageState extends State<WriteTipPage> {
  String _selectedCategory = '레시피';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<File> _selectedImages = [];

  final ImagePicker _picker = ImagePicker();

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    setState(() {
      for (var pickedFile in pickedFiles) {
        _selectedImages.add(File(pickedFile.path));
      }
    });
  }

  Future<void> _submitPost() async {
    final uri = Uri.parse('http://172.17.114.116:22222/tips/');

    final jsonData = {
      'title': _titleController.text,
      'contents': _contentController.text,
      'category': _getCategoryCode(_selectedCategory).toString(),
      'locationDong': '가좌동',
    };

    final request = http.MultipartRequest('POST', uri);

    // Add JSON data as fields
    request.fields['title'] = jsonData['title']!;
    request.fields['contents'] = jsonData['contents']!;
    request.fields['category'] = jsonData['category']!;
    request.fields['locationDong'] = jsonData['locationDong']!;

    // Add files if any
    if (_selectedImages.isNotEmpty) {
      for (var file in _selectedImages) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'raw_picture_list',
            file.path,
            filename: file.uri.pathSegments.last,
          ),
        );
      }
    }

    try {
      print(request.files);
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('Response: $responseBody');
        Navigator.pop(context);
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Failed with status code: ${response.statusCode}');
        print('Response body: $responseBody');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:
            const Text('글 쓰기', style: TextStyle(fontWeight: FontWeight.bold)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('분류', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    _buildCategoryChip('레시피', const Color(0xffD1D1D1)),
                    const SizedBox(width: 10),
                    _buildCategoryChip('관리', const Color(0xffD1D1D1)),
                    const SizedBox(width: 10),
                    _buildCategoryChip('특가', const Color(0xffD1D1D1)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: '내용을 입력해 주세요.',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              children: _selectedImages
                  .map((image) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(image, width: 100, height: 100),
                      ))
                  .toList(),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        backgroundColor: const Color(0xffECF6EA),
        child: const Icon(Icons.add, color: Colors.green),
      ),
    );
  }

  Widget _buildCategoryChip(String label, Color color) {
    return ChoiceChip(
      label: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 15)),
      selected: _selectedCategory == label,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = label;
        });
      },
      backgroundColor: color,
      selectedColor: const Color(0xff8DB600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40), // border radius 설정
        side: const BorderSide(width: 1, color: Colors.grey), // border width 설정
      ),
    );
  }

  int _getCategoryCode(String category) {
    switch (category) {
      case '레시피':
        return 0;
      case '관리':
        return 1;
      case '특가':
        return 2;
      default:
        return 0;
    }
  }
}

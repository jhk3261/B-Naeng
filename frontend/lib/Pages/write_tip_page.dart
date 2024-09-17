import 'package:flutter/material.dart';

class WriteTipPage extends StatefulWidget {
  const WriteTipPage({super.key});

  @override
  _WriteTipPageState createState() => _WriteTipPageState();
}

class _WriteTipPageState extends State<WriteTipPage> {
  String _selectedCategory = '레시피';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

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
              onPressed: () {
                // 게시물 올리기 기능 추가
              },
              child: const Text(
                '올리기',
                style: TextStyle(color: Colors.green, fontSize: 16),
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
            const Text('분류', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildCategoryChip('레시피', Colors.green),
                const SizedBox(width: 10),
                _buildCategoryChip('관리', Colors.grey),
                const SizedBox(width: 10),
                _buildCategoryChip('특가', Colors.grey),
              ],
            ),
            const SizedBox(height: 20),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 플러스 버튼 클릭 시 기능 추가
        },
        backgroundColor: Colors.green.withOpacity(0.1),
        child: const Icon(Icons.add, color: Colors.green),
      ),
    );
  }

  Widget _buildCategoryChip(String label, Color color) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      selected: _selectedCategory == label,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = label;
        });
      },
      backgroundColor: color,
      selectedColor: Colors.green,
    );
  }
}

import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Pages/share/tips/tip_detail.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/widgets/share/tips/receipe_element.dart';

class ShareTips extends StatefulWidget {
  final List<CameraDescription> cameras;

  const ShareTips({super.key, required this.cameras});

  @override
  _ShareTipsState createState() => _ShareTipsState();
}

class _ShareTipsState extends State<ShareTips> {
  List<Map<String, dynamic>> receipes = [];

  @override
  void initState() {
    super.initState();
    fetchReceipes();
  }

  Future<void> fetchReceipes() async {
    final url = Uri.parse('http://127.0.0.1:8000/tips');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        // isShared를 랜덤하게 추가
        // final random = Random();
        receipes = data.map((item) {
          return {
            'id': item['id'],
            // 'isShared': random.nextBool(), // true 또는 false 랜덤하게 설정
            'title': item['title'],
            'pictures': item['pictures'],
            'locationDong': item['locationDong'],
            'like_count': item['like_count'],
            'comment_count': item['comment_count'],
            'scrap_count': item['scrap_count'],
          };
        }).toList();

        // print(receipes);

        setState(() {});
      } else {
        throw Exception('Failed to load receipes');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: receipes.length,
                    itemBuilder: (context, index) {
                      final r = receipes[index];
                      return GestureDetector(
                        onTap: () {
                          // 터치 시 ReceipeDetailPage로 이동하면서 id를 전달
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReceipeDetailPage(id: r['id']),
                            ),
                          );
                        },
                        child: ReceipeShareElement(
                          id: r['id'],
                          // isShared: r['isShared'],
                          title: r['title'],
                          imgPath:
                              r['pictures'].isNotEmpty ? r['pictures'][0] : "",
                          locationDong: r['locationDong'],
                          like_count: r['like_count'],
                          comment_count: r['comment_count'],
                          scrap_count: r['scrap_count'],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

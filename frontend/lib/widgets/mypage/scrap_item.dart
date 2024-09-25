import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiUrl = 'http://127.0.0.1:8000';

class ScrapItemPage extends StatefulWidget {
  final int userId;

  const ScrapItemPage({super.key, required this.userId});

  @override
  _ScrapItemPageState createState() => _ScrapItemPageState();
}

class _ScrapItemPageState extends State<ScrapItemPage> {
  List<dynamic> scrapItems = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchScrapItems();
  }

  Future<void> fetchScrapItems() async {
    try {
      final userId = widget.userId;
      final response =
          await http.get(Uri.parse('$apiUrl/scraps?user_id=$userId'));

      if (response.statusCode == 200) {
        setState(() {
          scrapItems = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load scrap items');
      }
    } catch (e) {
      setState(() {
        scrapItems = [
          {
            'pictures': 'assets/images/image1.png',
            'title': '당근이 남아 돌 때 꿀 팁!!',
            'like_count': 122,
            'comment_count': 65,
            'scrap_count': 45,
            'created_at': '2023-06-28T00:00:00',
          },
          {
            'pictures': 'assets/images/image2.png',
            'title': '쌈 채소 드려요',
            'like_count': 62,
            'comment_count': 13,
            'scrap_count': 22,
            'created_at': '2023-05-12T00:00:00',
          },
          {
            'pictures': 'assets/images/image3.png',
            'title': '삼겹살 800g',
            'like_count': 5,
            'comment_count': 2,
            'scrap_count': 9,
            'created_at': '2023-07-02T00:00:00',
          },
          {
            'pictures': 'assets/images/image4.png',
            'title': '아보카도 덮밥 레시피',
            'like_count': 100,
            'comment_count': 10,
            'scrap_count': 15,
            'created_at': '2023-04-25T00:00:00',
          },
        ];
        isLoading = false;
        errorMessage = 'Failed to fetch from API, showing sample data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스크랩'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(errorMessage,
                        style: const TextStyle(color: Colors.red)),
                    Expanded(
                      child: buildScrapList(),
                    ),
                  ],
                )
              : buildScrapList(),
    );
  }

  Widget buildScrapList() {
    return ListView.builder(
      itemCount: scrapItems.length,
      itemBuilder: (context, index) {
        final scrapItem = scrapItems[index];
        return ScrapItemWidget(
          scrapItem: ScrapItem.fromJson(scrapItem), // ScrapItem 객체 생성
        );
      },
    );
  }
}

class ScrapItemWidget extends StatelessWidget {
  final ScrapItem scrapItem;

  const ScrapItemWidget({super.key, required this.scrapItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // 이미지 섹션
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                scrapItem.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16.0),
            // 텍스트 섹션
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scrapItem.title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 16.0, color: Colors.red),
                      const SizedBox(width: 4.0),
                      Text(scrapItem.likeCount.toString()),
                      const SizedBox(width: 16.0),
                      const Icon(Icons.comment, size: 16.0, color: Colors.blue),
                      const SizedBox(width: 4.0),
                      Text(scrapItem.commentCount.toString()),
                      const SizedBox(width: 16.0),
                      const Icon(Icons.bookmark, size: 16.0, color: Colors.green),
                      const SizedBox(width: 4.0),
                      Text(scrapItem.scrapCount.toString()),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    scrapItem.createdAt.split('T')[0], // 날짜만 추출하여 표시
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ScrapItem 모델 클래스
class ScrapItem {
  final int id;
  final String title;
  final String imageUrl;
  final int likeCount;
  final int commentCount;
  final int scrapCount;
  final String createdAt;

  ScrapItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.scrapCount,
    required this.createdAt,
  });

  factory ScrapItem.fromJson(Map<String, dynamic> json) {
    return ScrapItem(
      id: json['id'],
      title: json['title'],
      imageUrl: json['pictures'][0], // API의 JSON 구조에 맞게 수정
      likeCount: json['like_count'],
      commentCount: json['comment_count'],
      scrapCount: json['scrap_count'],
      createdAt: json['created_at'],
    );
  }
}
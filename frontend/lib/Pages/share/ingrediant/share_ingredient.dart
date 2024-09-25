import 'package:flutter/material.dart';
import 'package:frontend/widgets/friger/food_element.dart';
import 'package:camera/camera.dart';
import 'IngredientDetailPage.dart'; // 살세페이지
import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://172.17.114.116:22222';

// 식재료 생성 (POST 요청)
Future<void> createIngredient(
    int userId, String title, String contents, BuildContext context,
    {String? imageUrl, bool isShared = false}) async {
  final url = Uri.parse('$baseUrl/ingredients/');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': userId,
      'title': title,
      'contents': contents,
      'image_url': imageUrl,
      'is_shared': isShared,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('식재료 생성 성공!')),
    );
    print('Ingredient created: ${response.body}');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('식재료 생성 실패: ${response.statusCode}')),
    );
    print('Failed to create ingredient: ${response.statusCode}');
    throw Exception('Failed to create ingredient');
  }
}

class ShareIngredient extends StatelessWidget {
  final List<CameraDescription> cameras;

  const ShareIngredient({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> foodElements = [
      {
        'isShared': true,
        'title': '고기 나눠드려요~',
        'imgPath': 'assets/images/beef.jpg',
        'locationDong': '가좌동',
      },
      {
        'isShared': true,
        'title': '등갈비 남은거 가져가세요~',
        'imgPath': 'assets/images/backrip.jpg',
        'locationDong': '초전동',
      },
      {
        'isShared': false,
        'title': '라면 먹고 싶은데 김치가 없어요.. 김치 있으신 분?',
        'imgPath': 'assets/images/kimchi.jpg',
        'locationDong': '금산면',
      },
      {
        'isShared': true,
        'title': '스팸 많이 남아서 뿌립니다!!',
        'imgPath': 'assets/images/spam.jpg',
        'locationDong': '정촌면',
      },
      {
        'isShared': true,
        'title': '햇반 유효기한 두 달 남은거 다섯 팩',
        'imgPath': 'assets/images/rice.jpeg',
        'locationDong': '충무공동',
      }
    ];

    // const Text(
    //   "정보 나눔",
    //   style: TextStyle(
    //     fontSize: 20,
    //     fontWeight: FontWeight.bold,
    //     color: Color(0xFF449C4A),
    //   ),

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
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 5, // 간격 줄이기
                      mainAxisSpacing: 5, // 간격 줄이기
                    ),
                    itemCount: foodElements.length,
                    itemBuilder: (context, index) {
                      final food = foodElements[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IngredientDetailPage(
                                ingredientId: 1,
                                title: food['title'],
                                imageUrl: food['imgPath'],
                                description:
                                    '구매일자: 2024.09.05\n개인위치: 경상국립대학교 후문',
                              ),
                            ),
                          );
                        },
                        child: FoodElement(
                          isShared: food['isShared'],
                          title: food['title'],
                          imgPath: food['imgPath'],
                          locationDong: food['locationDong'],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

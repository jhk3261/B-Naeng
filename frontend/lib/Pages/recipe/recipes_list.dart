import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class RecipesRecommendList extends StatefulWidget {
  final List<CameraDescription> cameras;
  const RecipesRecommendList({super.key, required this.cameras});

  @override
  _RecipesRecommendList createState() => _RecipesRecommendList();
}

// fetch
Future<Map<String, dynamic>> fetchRecipes() async {
  final response = await http.get(Uri.parse(
      'http://127.0.0.1:8000/recipes/recommend?friger_id=1&user_id=1')); // id 수정 필요

  if (response.statusCode == 200) {
    print(jsonDecode(utf8.decode(response.bodyBytes)));
    return jsonDecode(utf8.decode(response.bodyBytes));
  } else {
    throw Exception('레시피 정보 불러오기 실패!!!');
  }
}

class _RecipesRecommendList extends State<RecipesRecommendList> {
  Future<Map<String, dynamic>>? _recipesFuture;
  int? focusedIndex;

  @override
  void initState() {
    super.initState();
    focusedIndex = 0;
    // fetchRecipes() 호출 후 데이터를 _recipesFuture에 저장
    _recipesFuture = fetchRecipes();
  }

  void toggleRecipe(int index) {
    setState(() {
      focusedIndex = (focusedIndex == index) ? null : index;
    });
  }

  void _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const FlutterSecureStorage storage = FlutterSecureStorage();

    Future<Map<String, dynamic>?> getUserInfo() async {
      final token = await storage.read(key: 'access_token');
      if (token == null) return null;

      // JWT로 payload 불러오기
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));

      // Json 으로 변환 후 반환
      return json.decode(decodedPayload);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.001),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              screenWidth * 0.08,
              0,
              screenWidth * 0.08,
              screenWidth * 0.04,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '비냉 추천 레시피',
                  style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF232323),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load recipes'));
          } else if (snapshot.hasData) {
            var recipes = snapshot.data!['recipes'];
            var additionalRecipes = snapshot.data!['additional_recipes'];
            var additionalIngredients =
                snapshot.data!['additional_ingredients'];

            // 데이터가 준비되면 UI 구성
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  children: [
                    Text(
                      '비냉 추천 메뉴',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff449C4A),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    ...recipes.map<Widget>((recipe) {
                      int index = recipes.indexOf(recipe);

                      bool isFocused = focusedIndex == index;
                      Color borderColor = isFocused
                          ? const Color(0xff8EC96D)
                          : const Color(0xffBCBCBC);
                      Color titleColor =
                          isFocused ? const Color(0xff449C4A) : Colors.black;

                      return GestureDetector(
                        onTap: () => toggleRecipe(index),
                        child: Column(
                          children: [
                            Container(
                              width: screenWidth * 0.84,
                              decoration: BoxDecoration(
                                  border: Border.all(color: borderColor),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe['title'],
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.045,
                                          fontWeight: FontWeight.w600,
                                          color: titleColor),
                                    ),
                                    if (focusedIndex == index)
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: screenWidth * 0.05),
                                          Text(
                                              '재료: ${recipe['ingredients'].join(', ')}'),
                                          SizedBox(height: screenWidth * 0.05),
                                          Text(
                                              '조리법: ${recipe['steps'].join('\n')}'),
                                          // Text(
                                          //   '조리법:\n${recipe['steps'].asMap().entries.map(
                                          //     (entry) {
                                          //       int index = entry.key +
                                          //           1; // 1부터 시작하는 번호
                                          //       String step = entry.value;
                                          //       return '$index. $step';
                                          //     },
                                          //   ).join('\n')}',
                                          // ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: screenWidth * 0.06,
                            )
                          ],
                        ),
                      );
                    }).toList(),
                    SizedBox(height: screenWidth * 0.04),
                    Text(
                      '추가 레시피',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff449C4A),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    ...additionalRecipes.map<Widget>((recipe) {
                      int index = additionalRecipes.indexOf(recipe);
                      List<dynamic> additionalIngredients =
                          snapshot.data!['additional_ingredients'][index];
                      bool isFocused = focusedIndex == index + recipes.length;
                      Color borderColor = isFocused
                          ? const Color(0xff8EC96D)
                          : const Color(0xffBCBCBC);
                      Color titleColor =
                          isFocused ? const Color(0xff449C4A) : Colors.black;

                      return GestureDetector(
                        onTap: () => toggleRecipe((index + recipes.length)
                            .toInt()), // focusedIndex 충돌 방지
                        child: Column(
                          children: [
                            Container(
                              width: screenWidth * 0.84,
                              decoration: BoxDecoration(
                                border: Border.all(color: borderColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe['title'],
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.045,
                                          fontWeight: FontWeight.w600,
                                          color: titleColor),
                                    ),
                                    if (focusedIndex ==
                                        index + recipes.length) // 중복되지 않도록
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: screenWidth * 0.05),
                                          Text(
                                              '재료: ${recipe['ingredients'].join(', ')}'),
                                          SizedBox(height: screenWidth * 0.04),
                                          GestureDetector(
                                            onTap: () => _launchURL(Uri.parse(
                                                'https://www.google.com')),
                                            child: Text(
                                              '추가 재료: ${additionalIngredients.join(', ')}',
                                              style: const TextStyle(
                                                color: Colors
                                                    .blue, // 클릭 가능한 링크처럼 보이게 하기 위해 색상 변경
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: screenWidth * 0.06),
                                          Text(
                                            '${recipe['steps'].asMap().entries.map((entry) {
                                              int index =
                                                  entry.key + 1; // 1부터 시작하는 번호
                                              String step = entry.value;
                                              return '$index. $step';
                                            }).join('\n')}',
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: screenWidth * 0.06,
                            )
                          ],
                        ),
                      );
                    }).toList(),
                    SizedBox(height: screenWidth * 0.2),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

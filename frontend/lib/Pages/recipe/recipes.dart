import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecipesRecommend extends StatefulWidget {
  final List<CameraDescription> cameras;
  const RecipesRecommend({super.key, required this.cameras});

  @override
  _RecipesRecommend createState() => _RecipesRecommend();
}

class _RecipesRecommend extends State<RecipesRecommend> {
  int? focusedIndex;
  Future<Map<String, List<Map<String, dynamic>>>>? _recipesFuture;

  @override
  void initState() {
    super.initState();
    focusedIndex = 0;
    _recipesFuture = fetchRecipes(); // 처음에만 데이터 불러오기
  }

  void toggleRecipe(int index) {
    setState(() {
      if (focusedIndex == index) {
        focusedIndex = null; // 드롭다운 닫기
      } else {
        focusedIndex = index; // 드롭다운 열기
      }
    });
  }

  // 서버에서 레시피 불러오기
  final int frigerId = 1; // 테스트용으로 frigerId를 1로 설정
  Future<Map<String, List<Map<String, dynamic>>>> fetchRecipes() async {
    final response = await http.get(Uri.parse(
        'http://127.0.0.1:22222/recipes/recommend?friger_id=$frigerId'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      // '레시피'와 '추가레시피' 각각 처리
      List<dynamic> recipeList = data['레시피'];
      List<dynamic> additionalRecipeList = data['추가레시피'];

      // JSON의 동적 리스트를 Map 리스트로 캐스팅
      List<Map<String, dynamic>> recipes =
          recipeList.cast<Map<String, dynamic>>();
      List<Map<String, dynamic>> additionalRecipes =
          additionalRecipeList.cast<Map<String, dynamic>>();

      return {
        'recipes': recipes,
        'additionalRecipes': additionalRecipes,
      };
    } else {
      throw Exception("Failed to load recipes");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _recipesFuture, // 이미 저장된 Future를 사용
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            // 데이터를 안전하게 불러온 후 처리
            List<Map<String, dynamic>> recipes = snapshot.data!['recipes']!;
            List<Map<String, dynamic>> additionalRecipes =
                snapshot.data!['additionalRecipes']!;

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        '비냉 추천 메뉴',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff449C4A),
                        ),
                      ),
                    ),
                    // 첫 번째 Column: 레시피
                    Column(
                      children: List.generate(recipes.length, (index) {
                        return RecipeItem(
                          title: recipes[index]['title'] as String,
                          ingredients:
                              (recipes[index]['ingredients'] as List<dynamic>)
                                  .join(', '),
                          steps: (recipes[index]['steps'] as List<dynamic>)
                              .join('\n'),
                          isFocused: focusedIndex == index,
                          onTap: () => toggleRecipe(index),
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                        );
                      }),
                    ),
                    SizedBox(
                      height: screenWidth * 0.04,
                    ),
                    Center(
                      child: Text(
                        '한 두개만 더 있다면',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff449C4A),
                        ),
                      ),
                    ), // 레시피와 추가 레시피 사이의 간격
                    SizedBox(
                      height: screenWidth * 0.04,
                    ),
                    // 두 번째 Column: 추가 레시피
                    Column(
                      children:
                          List.generate(additionalRecipes.length, (index) {
                        return RecipeItem(
                          title: additionalRecipes[index]['title'] as String,
                          ingredients: (additionalRecipes[index]['ingredients']
                                  as List<dynamic>)
                              .join(', '),
                          steps: (additionalRecipes[index]['steps']
                                  as List<dynamic>)
                              .join('\n'),
                          isFocused: focusedIndex == index,
                          onTap: () => toggleRecipe(index),
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Text(
              'No data available',
            );
          }
        },
      ),
    );
  }
}

class RecipeItem extends StatelessWidget {
  final String title;
  final String ingredients;
  final String steps;
  final bool isFocused;
  final VoidCallback onTap;
  final double screenHeight;
  final double screenWidth;

  const RecipeItem({
    super.key,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.isFocused,
    required this.onTap,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.05,
      ),
      child: GestureDetector(
        onTap: onTap, // Handle the click event to toggle the dropdown
        child: Container(
          width: screenWidth * 0.84,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xff8EC96D),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Row(
                  children: [
                    const Icon(
                      Icons.dinner_dining_rounded,
                      color: Color(0xff8EC96D),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      title,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff8EC96D),
                      ),
                    ),
                  ],
                ),
              ),
              // Show detailed information only if this recipe is focused
              if (isFocused)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ingredients: $ingredients',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Steps:\n$steps',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

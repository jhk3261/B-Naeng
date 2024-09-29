import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class RecipesRecommendList extends StatefulWidget {
  final List<CameraDescription> cameras;
  const RecipesRecommendList({super.key, required this.cameras});

  @override
  _RecipesRecommendList createState() => _RecipesRecommendList();
}

class _RecipesRecommendList extends State<RecipesRecommendList> {
  int? focusedIndex;

  // 초기화
  @override
  void initState() {
    super.initState();
    focusedIndex = 0;
    // _recipesFuture = fetchRecipes();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: const Padding(
          padding: EdgeInsets.fromLTRB(16, 30, 0, 8),
          child: Text(
            '비냉 추천 레시피',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                fontFamily: "GmarketSansMedium",
                color: Color(0xFF232323)),
          ),
        ),
      ),
      body: SingleChildScrollView(
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
            ],
          ),
        ),
      ),
    );
  }
}

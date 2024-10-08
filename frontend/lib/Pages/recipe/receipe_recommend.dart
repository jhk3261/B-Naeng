// 초안 디자인 레시피 추천
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/widgets/recipe/recipe_box_container.dart';

class ReceipeRecommend extends StatelessWidget {
  final List<CameraDescription> cameras;

  const ReceipeRecommend({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final categoryFontSize = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          loadJsonRr(),
          loadJsonAr(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
              'No data available',
            ));
          }
          final recipeData = snapshot.data![0];
          final additionalRecipeData = snapshot.data![1];

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(
                    top: screenWidth * 0.3), // Header 높이만큼 Padding
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenWidth * 0.08),
                      // =============== RECOMMEND RECIPE ===============
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '나의 냉장고 추천 메뉴',
                            style: TextStyle(
                              color: const Color(0xFF449C4A),
                              fontSize: categoryFontSize,
                              fontFamily: 'GmarketSans',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Color(0xFF449C4A),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.08),
                      // ============ RECOMMEND RECIPE BOXES ============
                      SizedBox(
                        height: screenWidth * 0.9,
                        child: PageView(
                          children: [
                            // RR first page
                            Recipeboxcontainer(
                              recipePage: 1,
                              recipeData: recipeData,
                            ),
                            // RR second page
                            Recipeboxcontainer(
                              recipePage: 2,
                              recipeData: recipeData,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.01),
                      // ========== RECOMMEND RECIPE PAGE  ==========
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.35),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 18,
                              color: Color(0xFF8EC96D),
                            ),
                            Icon(
                              Icons.circle,
                              size: 18,
                              color: Color(0xFFD9D9D9),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      // ============ ADDITIONAL RECOMMEND ============
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '한 두개만 더 있다면?',
                            style: TextStyle(
                              color: Color(0xFF449C4A),
                              fontSize: 20,
                              fontFamily: 'GmarketSans',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Color(0xFF449C4A),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      // ========== ADDITIONAL RECOMMEND BOXES ==========
                      SizedBox(
                        height: 350,
                        child: PageView(
                          children: [
                            // AR first page
                            Recipeboxcontainer(
                              recipePage: 1,
                              recipeData: additionalRecipeData,
                            ),
                            // AR second page
                            Recipeboxcontainer(
                              recipePage: 2,
                              recipeData: additionalRecipeData,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // =========== ADDITIONAL RECOMMEND PAGE ===========
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 140,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 18,
                              color: Color(0xFF8EC96D),
                            ),
                            Icon(
                              Icons.circle,
                              size: 18,
                              color: Color(0xFFD9D9D9),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                      // =============== FOOTER ===============
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 80),
                      Text(
                        '비냉 추천 레시피',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          fontFamily: "GmarketSans",
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<List<dynamic>> loadJsonRr() async {
  final String response =
      await rootBundle.loadString("assets/json/recipeData.json");
  final data = json.decode(response) as List<dynamic>;
  return data;
}

Future<List<dynamic>> loadJsonAr() async {
  final String response =
      await rootBundle.loadString("assets/json/additionalRecipeData.json");
  final data = json.decode(response) as List<dynamic>;
  return data;
}

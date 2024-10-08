import 'package:flutter/material.dart';
import 'package:frontend/widgets/friger/food_element.dart';
import 'package:camera/camera.dart';
import 'IngredientDetailPage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiUrl = 'http://127.0.0.1:8000';

Future<List<dynamic>> fetchIngredients() async {
  final url = Uri.parse('$apiUrl/ingredients/');

  try {
    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final List<dynamic> ingredients =
          jsonDecode((utf8.decode(response.bodyBytes)));
      return ingredients;
    } else {
      throw Exception(
          'Failed to load ingredients: ${response.statusCode} ${response.body}');
    }
  } catch (error) {
    throw Exception('Failed to load ingredients: $error');
  }
}

class ShareIngredient extends StatelessWidget {
  final List<CameraDescription> cameras;

  const ShareIngredient({super.key, required this.cameras});

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
                  child: FutureBuilder<List<dynamic>>(
                    future: fetchIngredients(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('아직 적힌 나눔글이 없습니다.'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No ingredients available.'));
                      }

                      final foodElements = snapshot.data!;

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        itemCount: foodElements.length,
                        itemBuilder: (context, index) {
                          final food = foodElements[index];
                          final List<dynamic> pictures = food['pictures'] ?? [];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IngredientDetailPage(
                                    id: food['id'],
                                  ),
                                ),
                              ).then((_) {});
                            },
                            child: FoodElement(
                              isShared: food['is_shared'],
                              title: food['title'],
                              imgPath: pictures.isNotEmpty
                                  ? pictures[0]
                                  : 'assets/images/noimg.jpg',
                              locationDong: food['locationDong'],
                            ),
                          );
                        },
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

import 'package:flutter/material.dart';
import 'package:frontend/widgets/recipe_box.dart';

class Recipeboxcontainer extends StatelessWidget {
  final int recipePage;
  final List<dynamic> recipeData;

  const Recipeboxcontainer({
    super.key,
    required this.recipePage,
    required this.recipeData,
  });

  // RECOMMEND BOXES
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Recipebox(
                recipeItem: recipeData[recipePage < 2 ? 0 : 4],
              ),
              Recipebox(
                recipeItem: recipeData[recipePage < 2 ? 1 : 5],
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Recipebox(
                recipeItem: recipeData[recipePage < 2 ? 2 : 6],
              ),
              Recipebox(
                recipeItem: recipeData[recipePage < 2 ? 3 : 7],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

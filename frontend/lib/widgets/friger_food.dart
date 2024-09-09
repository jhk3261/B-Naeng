import 'package:flutter/material.dart';

class FrigerFood extends StatelessWidget {
  //개수, 디데이, 이미지, 품목명, 색상(3개)
  final String num;
  final int day;
  final String imagePath;
  final String food;
  final Color bgColor;
  final Color bdColor;
  final Color ftColor;

  const FrigerFood({
    super.key,
    required this.num,
    required this.day,
    required this.imagePath,
    required this.food,
    required this.bgColor,
    required this.bdColor,
    required this.ftColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topRight,
      children: [
        Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: bdColor,
                  width: 1,
                )),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    "D-$day",
                    style: TextStyle(
                      fontFamily: 'GmarketSansBold',
                      fontSize: 10,
                      color: ftColor,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Image.asset(
                    imagePath,
                    height: 40,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    food,
                    style: const TextStyle(
                      fontFamily: 'GmarketSans',
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            )),
        Positioned(
          top: -10,
          right: -10,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bdColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  fontFamily: 'GmarketSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

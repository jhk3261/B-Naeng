import 'package:flutter/material.dart';

class FoodElement extends StatelessWidget {
  final bool isShared;
  final String title;
  final String imgPath;
  final String locationDong;

  const FoodElement({
    super.key,
    required this.isShared,
    required this.title,
    required this.imgPath,
    required this.locationDong,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            // 이미지
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), // BorderRadius 설정
                image: DecorationImage(
                  image: AssetImage(imgPath),
                  fit: BoxFit.cover, // 이미지 비율 유지, 잘라내기
                ),
              ),
            ),
            // 조건부 렌더링
            if (isShared)
              Positioned.fill(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), // 반투명 회색 배경
                    borderRadius: BorderRadius.circular(15), // BorderRadius 설정
                  ),
                  child: const Center(
                    child: Text(
                      '나눔완료',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          width: 150,
          // 이미지와 동일한 너비 설정
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis, // 생략 설정
            softWrap: false, // 줄바꿈 방지
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(locationDong),
      ],
    );
  }
}

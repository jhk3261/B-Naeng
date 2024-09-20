import 'package:flutter/material.dart';
import 'package:frontend/Pages/food_create.dart';

class PlusBtn extends StatelessWidget {
  // final List<CameraDescription> cameras;

  const PlusBtn({super.key});

  void CreateFood(BuildContext context) {
    showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            title: Text(
              '재고등록방법을 선택해주세요',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF449C4A),
                    foregroundColor: Colors.white,
                    minimumSize: Size(200, 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {},
                  //TO DO : 영수증등록화면 네비게이션
                  child: Text(
                    '영수증 등록',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8EC96D),
                    foregroundColor: Colors.white,
                    minimumSize: Size(200, 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FoodCreate()),
                    );
                  },
                  child: Text(
                    '직접 등록',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ElevatedButton(
        onPressed: () => CreateFood(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF2F2F2),
          shape: CircleBorder(),
          padding: EdgeInsets.all(5),
        ),
        child: Transform.translate(
          offset: const Offset(0, -4),
          child: const Text(
            "+",
            style: TextStyle(
                fontSize: 40,
                color: Color(0xFFCBCBCB),
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Pages/friger/bill_scanner.dart';
import 'package:frontend/Pages/friger/food_create.dart';

class PlusBtn extends StatelessWidget {
  final List<CameraDescription> cameras;
  final int currentFridgeId;
  final VoidCallback onFoodAdded; // Callback 추가

  const PlusBtn(
      {super.key,
      required this.cameras,
      required this.currentFridgeId,
      required this.onFoodAdded});

  static double scaleWidth(BuildContext context) {
    const designGuideWidth = 430;
    final diff = MediaQuery.of(context).size.width / designGuideWidth;
    return diff;
  }

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
            title: const Text(
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
                    backgroundColor: const Color(0xFF449C4A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BillScan(
                                cameras: cameras,
                              )),
                    );
                  },
                  //TO DO : 영수증등록화면 네비게이션
                  child: Text(
                    '영수증 등록',
                    style: TextStyle(
                      fontSize: 24 * scaleWidth(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8EC96D),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodCreate(
                            currentFrige: currentFridgeId,
                            onFoodAdded: onFoodAdded,
                          ),
                        ) // Callback 전달)),
                        );
                  },
                  child: Text(
                    '직접 등록',
                    style: TextStyle(
                      fontSize: 24 * scaleWidth(context),
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
          backgroundColor: const Color(0xFF303030),
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(5),
        ),
        child: Transform.translate(
          offset: const Offset(0, 0),
          child: const Text(
            "+",
            style: TextStyle(
                fontSize: 44,
                color: Color(0xFF8DB600),
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

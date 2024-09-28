import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Pages/friger/bill_scanner.dart';
import 'package:frontend/Pages/friger/food_create.dart';
import 'package:frontend/Pages/friger/food_create_with_cam.dart';

class PlusBtn extends StatelessWidget {
  final List<CameraDescription> cameras;

  const PlusBtn({super.key, required this.cameras});

  void CreateFood(BuildContext context) {
    final List<Map<String, dynamic>> foodData = [
      {"name": "종이컵(일반 750/50P/1줄)나", "quantity": 3},
      {"name": "영실업 케이블CtoC 고속1M 한쪽 90도/코드웨이", "quantity": 1},
      // {"name": "크리넥스디럭스미니맥시", "quantity": 1},
      // {"name": "해피홈베이트작은바퀴용유한양행", "quantity": 1},
      // {"name": "크리넥스수앤수코튼오리지널물티슈(72P)", "quantity": 6}
    ];
    int frigerId = 1;
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
                  child: const Text(
                    '영수증 등록',
                    style: TextStyle(
                      fontSize: 24,
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
                        builder: (context) => const FoodCreate(),
                        // builder: (context) => FoodCreateSwipe(
                        //   ingredients: foodData,
                        //   frigerId: frigerId,
                        // ),
                      ),
                    );
                  },
                  child: const Text(
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

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Pages/bill_scanner.dart';
import 'package:frontend/Pages/food_create.dart';

class PlusBtn extends StatelessWidget {
  // final List<CameraDescription> cameras;

  const PlusBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              // builder: (context) => BillScan(
              //       cameras: cameras,
              //     )),
              builder: (context) => FoodCreate()),
        );
      },
      child: Container(
        width: 54,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(50),
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

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Pages/bill_scanner.dart';

class PlusBtn extends StatelessWidget {
  final List<CameraDescription> cameras;

  const PlusBtn({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BillScan(
                    cameras: cameras,
                  )),
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

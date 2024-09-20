import 'package:flutter/material.dart';

class ConfirmBtn extends StatelessWidget {
  const ConfirmBtn({
    super.key,
    required this.content,
  });

  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFF449C4A),
      ),
      child: TextButton(
        onPressed: () {},
        child: Text(
          content,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

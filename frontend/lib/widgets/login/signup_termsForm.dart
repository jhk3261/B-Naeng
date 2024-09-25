import 'package:flutter/material.dart';

class SignupTermsForm extends StatelessWidget {
  final String termsTitle;
  final String termsDetail;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const SignupTermsForm({
    super.key,
    required this.termsTitle,
    required this.termsDetail,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: isChecked,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              checkColor: const Color(0xfff9f9f9),
              activeColor: const Color(0xff8EC96D),
              side: const BorderSide(
                color: Color(0xffE5E5E5),
                width: 1,
              ),
              materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
            const SizedBox(
              width: 8,
            ),
            const Text(
              '(필수)',
              style: TextStyle(
                color: Color(0xff8EC96D),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              termsTitle,
              style: const TextStyle(
                color: Color(0xff232323),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          height: 100,
          // border 추가 필요
          color: const Color(0xfff9f9f9),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 8.0,
              ),
              child: Text(
                termsDetail,
                style: const TextStyle(
                  color: Color(0xffB4B4B4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

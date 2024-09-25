import 'package:flutter/material.dart';

class SignupFormBox extends StatelessWidget {
  final String formTitle, formGuide;
  final double titleFontSize;
  final bool requiredField;
  final TextEditingController fieldController;
  // final String formType;

  const SignupFormBox({
    super.key,
    required this.formTitle,
    required this.formGuide,
    required this.titleFontSize,
    required this.requiredField,
    required this.fieldController,
    // required this.formType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formTitle,
              style: TextStyle(
                color: const Color(0xFF232323),
                fontWeight: FontWeight.w500,
                fontSize: titleFontSize,
              ),
            ),
            const SizedBox(width: 5),
            if (requiredField)
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xffFF8686),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: fieldController,
          decoration: InputDecoration(
            labelText: formGuide,
            border: const OutlineInputBorder(),
            fillColor: const Color(0xFFCBCBCB),
          ),
        ),
      ],
    );
  }
}

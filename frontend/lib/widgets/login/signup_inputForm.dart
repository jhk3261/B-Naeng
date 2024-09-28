// import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter/material.dart';

class SignupFormBox extends StatelessWidget {
  final String formTitle, formGuide;
  final double titleFontSize;
  final bool requiredField;
  final TextEditingController fieldController;
  final bool validInputForm;
  final Function(bool)? onInputChanged;
  final VoidCallback? selectDate;
  // final String formType;

  const SignupFormBox({
    super.key,
    required this.formTitle,
    required this.formGuide,
    required this.titleFontSize,
    required this.requiredField,
    required this.fieldController,
    required this.validInputForm,
    this.onInputChanged,
    this.selectDate,
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
        formTitle == '닉네임' 
            ? TextFormField(
                controller: fieldController,
                decoration: InputDecoration(
                  labelText: formGuide,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: validInputForm
                            ? const Color(0xff8ec960)
                            : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8)),
                  fillColor: const Color(0xFFCBCBCB),
                ),
                onChanged: (value) {
                  if (value.length >= 2 && value.length <= 8) {
                    if (onInputChanged != null) {
                      onInputChanged!(true);
                    }
                  } else {
                    if (onInputChanged != null) {
                      onInputChanged!(false);
                    }
                  }
                },
              )
            : formTitle == '생년월일'
                ? TextFormField(
                    controller: fieldController,
                    decoration: InputDecoration(
                      labelText: formGuide,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: validInputForm
                              ? const Color(0xff8ec960)
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        onPressed: selectDate,
                        icon: const Icon(
                          Icons.calendar_today_rounded,
                        ),
                      ),
                      fillColor: const Color(0xFFCBCBCB),
                    ),
                    onChanged: (value) {
                      final isValidDateFormat = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                      if (isValidDateFormat.hasMatch(value)) {
                        onInputChanged?.call(true);
                      } else {
                        onInputChanged?.call(false);
                      }
                    },
                  )
                : TextFormField(
                    controller: fieldController,
                    decoration: InputDecoration(
                      labelText: formGuide,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: validInputForm
                              ? const Color(0xff8ec960)
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      fillColor: const Color(0xFFCBCBCB),
                    ),
                    onChanged: (value) {
                      if (value.length >= 2 && value.length <= 8) {
                        if (onInputChanged != null) {
                          onInputChanged!(true);
                        }
                      } else {
                        if (onInputChanged != null) {
                          onInputChanged!(false);
                        }
                      }
                    },
                  ),
      ],
    );
  }
}

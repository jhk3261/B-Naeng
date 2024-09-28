import 'package:flutter/material.dart';

class frigerItem extends StatelessWidget {
  final Map<String, dynamic> frigerData;
  final bool isSelected;
  final Function() onTap;

  frigerItem({
    super.key,
    required this.frigerData,
    required this.isSelected,
    required this.onTap,
  });

  static double scaleWidth(BuildContext context) {
    const designGuideWidth = 430;
    final diff = MediaQuery.of(context).size.width / designGuideWidth;
    return diff;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(
            'assets/images/frigerLogo.png',
            height: 56,
          ),
          SizedBox(
            width: 16 * scaleWidth(context),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '${frigerData['name']} 냉장고',
                style: TextStyle(
                  fontSize: 20 * scaleWidth(context),
                  color: isSelected ? Color(0xFF449C4A) : Color(0xFF232323),
                ),
              ),
              Text(
                '멤버(${frigerData['user_count']}명)',
                style: TextStyle(
                  fontSize: 16 * scaleWidth(context),
                  color: Color(0xFFCBCBCB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

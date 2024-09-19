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
            width: 16,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '${frigerData['name']} 냉장고',
                style: TextStyle(
                  fontSize: 20,
                  color: isSelected ? Color(0xFF449C4A) : Color(0xFF232323),
                ),
              ),
              Text(
                '멤버(${frigerData['user_count']}명)',
                style: TextStyle(
                  fontSize: 16,
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

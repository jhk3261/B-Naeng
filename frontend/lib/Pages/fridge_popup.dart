import 'package:flutter/material.dart';

class FridgePopup extends StatelessWidget {
  const FridgePopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '냉장고 소유 목록',
                  style: TextStyle(fontSize: 18),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.close, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildFridgeItem(context, '현재 선택된 냉장고', true),
                  _buildFridgeItem(context, '2번 냉장고', false),
                  _buildFridgeItem(context, '3번 냉장고', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFridgeItem(BuildContext context, String title, bool isSelected) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.green : Colors.black,
        ),
      ),
      trailing: const Text(
        '관리',
        style: TextStyle(color: Colors.grey),
      ),
      onTap: () {
        // 냉장고 관리 로직
      },
    );
  }
}

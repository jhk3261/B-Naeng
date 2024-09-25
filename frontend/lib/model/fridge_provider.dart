import 'package:flutter/material.dart';

class FridgeProvider with ChangeNotifier {
  List<Map<String, dynamic>> _fridgeList = [
    {'name': '홍길동', 'user_count': 1, 'iscurrent': true},
    {'name': '이디야 초전점', 'user_count': 4, 'iscurrent': false},
    {'name': '본가', 'user_count': 3, 'iscurrent': false},
  ];

  List<Map<String, dynamic>> get fridgeList => _fridgeList;

  void changeCurrentFridge(String newFridgeName) {
    for (var fridge in _fridgeList) {
      fridge['iscurrent'] = fridge['name'] == newFridgeName;
    }
    notifyListeners(); // 상태 변경 알림
  }
}

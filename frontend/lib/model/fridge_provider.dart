import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FridgeProvider with ChangeNotifier {
  List<Map<String, dynamic>> _fridgeList = [];
  Map<String, dynamic>? _currentFridge; // 현재 냉장고를 저장할 변수 추가

  // 서버에서 냉장고 목록 가져오기
  Future<void> fetchFridgeList() async {
    final url = Uri.parse('http://127.0.0.1:8000/frigers'); // 필요에 따라 URL 조정
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print(data);
        setFridgeList(data
            .map((fridge) => {
                  'id': fridge['id'],
                  'name': fridge['name'],
                  'inventory_count': fridge['inventory_count'],
                })
            .toList());
      } else {
        throw Exception('Failed to load fridges');
      }
    } catch (e) {
      print(e);
      // 예외 처리 추가 가능
    }
  }

  void setFridgeList(List<Map<String, dynamic>> fridgeList) {
    _fridgeList = fridgeList;
    _currentFridge =
        _fridgeList.isNotEmpty ? _fridgeList[0] : null; // 첫 번째 냉장고를 현재 냉장고로 설정
    notifyListeners();
  }

  List<Map<String, dynamic>> get fridgeList => _fridgeList;

  Map<String, dynamic>? get currentFridge => _currentFridge;
  // List<Map<String, dynamic>> _fridgeList = [
  //   {'name': '홍길동', 'user_count': 1, 'iscurrent': true},
  //   {'name': '이디야 초전점', 'user_count': 4, 'iscurrent': false},
  //   {'name': '본가', 'user_count': 3, 'iscurrent': false},
  // ];

  // void changeCurrentFridge(String newFridgeName) {
  //   for (var fridge in _fridgeList) {
  //     fridge['iscurrent'] = fridge['name'] == newFridgeName;
  //   }
  //   notifyListeners(); // 상태 변경 알림
  // }
  void changeCurrentFridge(String newFridgeName) {
    _currentFridge = _fridgeList.firstWhere(
      (fridge) => fridge['name'] == newFridgeName,
    );
    notifyListeners();
  }
}

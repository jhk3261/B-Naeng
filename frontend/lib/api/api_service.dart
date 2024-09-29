import 'package:http/http.dart' as http;
import 'dart:convert';

// API 서버의 URL
const String apiUrl = 'https://example.com/api';

// 사용자 프로필 정보 가져오기
Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
  final response = await http.get(Uri.parse('$apiUrl/users/profile/$userId'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load user profile');
  }
}

// 보유 중인 그린 포인트 가져오기
Future<int> fetchUserPoints(String userId) async {
  final response = await http.get(Uri.parse('$apiUrl/users/points/$userId'));

  if (response.statusCode == 200) {
    return json.decode(response.body)['points'];
  } else {
    throw Exception('Failed to load user points');
  }
}

// 냉장고 목록 가져오기
Future<List<dynamic>> fetchFridgeData(String userId) async {
  final response = await http.get(Uri.parse('$apiUrl/users/fridges/$userId'));

  if (response.statusCode == 200) {
    return json.decode(response.body)['fridges'];
  } else {
    throw Exception('Failed to load fridge data');
  }
}

// 스크랩 목록 가져오기
Future<List<dynamic>> fetchScrapItems(String userId) async {
  final response = await http.get(Uri.parse('$apiUrl/users/scraps/$userId'));

  if (response.statusCode == 200) {
    return json.decode(response.body)['scraps'];
  } else {
    throw Exception('Failed to load scrap items');
  }
}

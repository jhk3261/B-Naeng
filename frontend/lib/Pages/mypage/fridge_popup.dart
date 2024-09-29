import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiUrl = 'http://127.0.0.1:8000';

class AppUser {
  final int id;
  final String username;

  AppUser({required this.id, required this.username});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      username: json['username'],
    );
  }
}

// 냉장고(Friger) 모델
// Friger 모델
class Friger {
  final int id;
  final String name;
  final bool isSelected;
  final int ownerId;
  final int currentUserId = 1;
  final List<AppUser> userList;

  Friger({
    required this.id,
    required this.name,
    required this.isSelected,
    required this.ownerId,
    required this.userList,
  });

  factory Friger.fromJson(Map<String, dynamic> json) {
    return Friger(
      id: json['id'],
      name: json['name'],
      isSelected:
          json.containsKey('isSelected') ? json['isSelected'] : false, // 기본값 설정
      ownerId: json['owner_id'],
      userList: (json['users'] as List<dynamic>?)
              ?.map((user) => AppUser.fromJson(user))
              .toList() ??
          [], // null일 경우 빈 리스트 반환
    );
  }
}

class FridgePopup extends StatefulWidget {
  const FridgePopup({super.key});

  @override
  _FridgePopupState createState() => _FridgePopupState();
}

class _FridgePopupState extends State<FridgePopup> {
  List<Friger> _fridges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFridges();
  }

  Future<void> _fetchFridges() async {
    try {
      const userId = 1;
      final response =
          await http.get(Uri.parse('$apiUrl/users/$userId/frigers/'));

      if (response.statusCode == 200) {
        List<dynamic> frigerJson =
            jsonDecode((utf8.decode(response.bodyBytes)));

        // JSON 데이터 구조 확인
        if (frigerJson.isEmpty) {
        } else {}

        // Friger 객체로 변환
        List<Friger> fridges = frigerJson.map((json) {
          return Friger.fromJson(json);
        }).toList();

        setState(() {
          _fridges = fridges;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load fridges');
      }
    } catch (e) {
      setState(() {
        _fridges = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('냉장고 정보를 불러오는 데 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '냉장고 소유 목록',
                  style: TextStyle(fontSize: 20, fontFamily: 'GmarketSansBold'),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _fridges.isEmpty
                      ? const Center(child: Text('등록된 냉장고가 없습니다.'))
                      : ListView.builder(
                          itemCount: _fridges.length,
                          itemBuilder: (context, index) {
                            final friger = _fridges[index];

                            bool isAdmin =
                                friger.ownerId == friger.currentUserId;
                            return _buildFridgeItem(
                              context,
                              friger.id,
                              friger.name,
                              friger.isSelected,
                              isAdmin,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFridgeItem(BuildContext context, int fridgeId, String title,
      bool isSelected, bool isAdmin) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.green : Colors.black,
        ),
      ),
      trailing: isAdmin
          ? const Text(
              '관리',
              style: TextStyle(color: Colors.grey),
            )
          : null,
      onTap: () {
        if (isAdmin) {
          _showAdminPopup(context, fridgeId, title);
        } else {
          _showUserPopup(context, title);
        }
      },
    );
  }

  // 관리자용 팝업
  void _showAdminPopup(BuildContext context, int fridgeId, String fridgeName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AdminFridgeDialog(fridgeId: fridgeId, fridgeName: fridgeName);
      },
    );
  }

  // 일반 사용자용 팝업
  void _showUserPopup(BuildContext context, String fridgeName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('선택한 냉장고: $fridgeName',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildUserFridgeItem('신지아'),
                      _buildUserFridgeItem('야지신'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('나가기'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserFridgeItem(String userName) {
    return ListTile(
      title: Text(userName),
    );
  }
}

// 관리자용 다이얼로그
class AdminFridgeDialog extends StatefulWidget {
  final int fridgeId;
  final String fridgeName;

  const AdminFridgeDialog(
      {super.key, required this.fridgeId, required this.fridgeName});

  @override
  _AdminFridgeDialogState createState() => _AdminFridgeDialogState();
}

class _AdminFridgeDialogState extends State<AdminFridgeDialog> {
  List<AppUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // 특정 냉장고의 유저 목록 가져오기
  Future<void> _fetchUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$apiUrl/frigers/${widget.fridgeId}/users/'));

      if (response.statusCode == 200) {
        List<dynamic> usersJson = jsonDecode(response.body);

        // JSON을 AppUser 리스트로 변환
        List<AppUser> fetchedUsers =
            usersJson.map((json) => AppUser.fromJson(json)).toList();

        // 현재 유저 ID가 목록에 없으면 추가
        const int currentUserId = 1;
        bool currentUserExists =
            fetchedUsers.any((user) => user.id == currentUserId);

        if (!currentUserExists) {
          fetchedUsers.add(AppUser(id: currentUserId, username: '현재 유저'));
        }

        setState(() {
          _users = fetchedUsers;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() {
        _users = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유저 목록을 불러오는 데 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(16.0),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '냉장고: ${widget.fridgeName}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                      ? const Center(child: Text('등록된 유저가 없습니다.'))
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return _buildUserItem(user.username);
                          },
                        ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Color(0xFF449C4A)),
                  shadowColor: WidgetStatePropertyAll(Colors.transparent),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  '닫기',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(String userName) {
    return ListTile(
      title: Text(userName),
    );
  }
}

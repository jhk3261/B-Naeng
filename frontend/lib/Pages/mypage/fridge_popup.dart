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
class Friger {
  final int id;
  final String name;
  final bool isSelected;
  final int ownerId;
  final int currentUserId;
  final List<AppUser> userList;

  Friger({
    required this.id,
    required this.name,
    required this.isSelected,
    required this.ownerId,
    required this.currentUserId,
    required this.userList,
  });

  factory Friger.fromJson(Map<String, dynamic> json) {
    return Friger(
      id: json['id'],
      name: json['name'],
      isSelected: json['isSelected'],
      ownerId: json['owner_id'],
      currentUserId: json['current_user_id'],
      userList: (json['users'] as List)
          .map((user) => AppUser.fromJson(user))
          .toList(),
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
      const userId = 1; // 조회하고자 하는 유저의 ID
      final response =
          await http.get(Uri.parse('$apiUrl/users/$userId/frigers/'));

      if (response.statusCode == 200) {
        List<dynamic> frigerJson = jsonDecode(response.body);
        print('Fetched fridges JSON: $frigerJson'); // 추가: 서버에서 받은 JSON 데이터 출력

        // Friger 객체로 변환
        List<Friger> fridges =
            frigerJson.map((json) => Friger.fromJson(json)).toList();
        print('Mapped Friger objects: $fridges'); // 추가: 변환된 Friger 객체 출력

        setState(() {
          _fridges = fridges;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load fridges');
      }
    } catch (e) {
      setState(() {
        _fridges = _fridges;
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: 400, // 높이를 늘려 유저 목록 표시 공간 확보
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _fridges.isEmpty
                      ? const Center(child: Text('등록된 냉장고가 없습니다.'))
                      : ListView.builder(
                          itemCount: _fridges.length,
                          itemBuilder: (context, index) {
                            final friger = _fridges[index];
                            print('Rendering fridge: ${friger.name}');
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
    print('Building fridge item: $title'); // 추가: 냉장고 아이템 빌드 확인
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
  final TextEditingController _userIdController = TextEditingController();

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
        setState(() {
          _users = usersJson.map((json) => AppUser.fromJson(json)).toList();
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

  // 유저 추가 함수
  Future<void> _addUser(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/frigers/${widget.fridgeId}/users/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{'user_id': userId}),
      );

      if (response.statusCode == 200) {
        _fetchUsers(); // 유저 목록 새로고침
      } else {
        throw Exception('Failed to add user');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유저 추가에 실패했습니다.')),
      );
    }
  }

  // 유저 삭제 함수
  Future<void> _removeUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/frigers/${widget.fridgeId}/users/$userId/'),
      );

      if (response.statusCode == 200) {
        _fetchUsers(); // 유저 목록 새로고침
      } else {
        throw Exception('Failed to remove user');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유저 삭제에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
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
                            return _buildUserItem(user.id, user.username);
                          },
                        ),
            ),
            _buildAddUserField(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(int userId, String userName) {
    return ListTile(
      title: Text(userName),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          _removeUser(userId);
        },
      ),
    );
  }

  Widget _buildAddUserField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _userIdController,
            decoration: const InputDecoration(
              labelText: '유저 ID 추가',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            final userId = int.tryParse(_userIdController.text);
            if (userId != null) {
              _addUser(userId);
              _userIdController.clear();
            }
          },
        ),
      ],
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiUrl = 'http://127.0.0.1:8000';

class FridgePopup extends StatefulWidget {
  const FridgePopup({super.key});

  @override
  _FridgePopupState createState() => _FridgePopupState();
}

class _FridgePopupState extends State<FridgePopup> {
  List<dynamic> _fridges = [];

  @override
  void initState() {
    super.initState();
    _fetchFridges();
  }

  // 냉장고 소유 목록 및 관리자 여부 가져오기
  Future<void> _fetchFridges() async {
    final response = await http.get(Uri.parse('$apiUrl/frigers/my/'));

    if (response.statusCode == 200) {
      setState(() {
        _fridges = jsonDecode(response.body);
      });
    } else {
      print('Failed to load fridges');
    }
  }

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
              child: ListView.builder(
                itemCount: _fridges.length,
                itemBuilder: (context, index) {
                  final fridge = _fridges[index];
                  bool isAdmin = fridge['owner_id'] == fridge['current_user_id'];
                  return _buildFridgeItem(
                      context, fridge['name'], fridge['isSelected'], isAdmin);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFridgeItem(
      BuildContext context, String title, bool isSelected, bool isAdmin) {
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
          _showAdminPopup(context, title);
        } else {
          _showUserPopup(context, title);
        }
      },
    );
  }

  // 관리자용 팝업
  void _showAdminPopup(BuildContext context, String fridgeName) {
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
                const Text('선택한 냉장고 이름', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildAdminFridgeItem('신지아'),
                      _buildAdminFridgeItem('야지신'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // 냉장고 이름 추가 로직
                      },
                      child: const Icon(Icons.add_circle_outline,
                          color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminFridgeItem(String adminName) {
    return ListTile(
      title: Text(adminName),
      trailing: GestureDetector(
        onTap: () {
          // 삭제 로직
        },
        child: const Icon(Icons.remove_circle, color: Colors.red),
      ),
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
                const Text('선택한 냉장고 이름', style: TextStyle(fontSize: 18)),
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

  Widget _buildUserFridgeItem(String adminName) {
    return ListTile(
      title: Text(adminName),
    );
  }
}
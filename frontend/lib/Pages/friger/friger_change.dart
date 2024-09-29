import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/friger/friger_item.dart';
import 'package:http/http.dart' as http;

class FrigerChange extends StatefulWidget {
  final int currentFridgeId;

  const FrigerChange({super.key, required this.currentFridgeId});

  @override
  State<FrigerChange> createState() => _FrigerChangeState();
}

class _FrigerChangeState extends State<FrigerChange> {
  List<Map<String, dynamic>> _frigerList = [];

  int get currentFridgeId => widget.currentFridgeId; //현재 냉장고 id
  Map<String, dynamic>? selectedFridge;

  //특정 냉장고 인벤토리 데이터 가져오는 함수
  Future FetchFrigerList() async {
    final url = Uri.parse('http://127.0.0.1:8000/frigers/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // JSON이 List 형태로 반환되는 경우
        List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        // 각 리스트 아이템을 getFrigerList 객체로 변환
        return jsonList.map((json) => getFrigerList.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load list');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    return null;
  }

  // 서버에서 데이터를 가져와 _inventoryList를 업데이트하는 함수
  void fetchData() async {
    // FetchInventory 함수 호출
    List<getFrigerList>? FrigerList = await FetchFrigerList();

    if (FrigerList != null && FrigerList.isNotEmpty) {
      // 서버에서 받은 데이터를 _frigerList로 변환 및 업데이트
      setState(() {
        _frigerList = FrigerList.map((friger) => {
              "id": friger.id,
              "name": friger.name,
              "inventory_count": friger.inventory_count,
              "user_count": friger.user_count,
            }).toList();
      });
      // 현재 냉장고를 선택된 냉장고로 설정
      selectedFridge = _frigerList.firstWhere(
        (fridge) => fridge['id'] == currentFridgeId,
      );
    } else {
      print('No data found');
    }
  }

  static double scaleWidth(BuildContext context) {
    const designGuideWidth = 430;
    final diff = MediaQuery.of(context).size.width / designGuideWidth;
    return diff;
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final currentFridge = _frigerList.isNotEmpty
        ? _frigerList.firstWhere((fridge) => fridge['id'] == currentFridgeId)
        : {'id': 0, 'name': '데이터 로드 중...', 'inventory_count': 0}; // 데이터 로드 중 상태

    final includedFridges =
        _frigerList.where((fridge) => fridge['id'] != currentFridgeId).toList();

    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          centerTitle: false,
          surfaceTintColor: Colors.white,
          shadowColor: Colors.black,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: const Text(
            "냉장고 변경",
            style: TextStyle(
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '현재 냉장고',
                          style: TextStyle(
                            fontSize: 24 * scaleWidth(context),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF232323),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        frigerItem(
                            frigerData: currentFridge,
                            isSelected: selectedFridge == currentFridge,
                            onTap: () {
                              setState(() {
                                selectedFridge =
                                    currentFridge; // 현재 냉장고를 선택 상태로 설정
                              });
                            })
                      ],
                    ),
                  )),
              const SizedBox(
                height: 8,
              ),
              const Divider(
                color: Color(0xFFDCDCDC),
              ),
              const SizedBox(
                height: 16,
              ),
              Flexible(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '포함된 냉장고',
                          style: TextStyle(
                            fontSize: 24 * scaleWidth(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: includedFridges.length,
                            itemBuilder: (context, index) {
                              var friger = includedFridges[index];
                              bool isSelected = selectedFridge == friger;
                              return frigerItem(
                                  frigerData: friger,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      selectedFridge = friger; // 선택된 냉장고 업데이트
                                    });
                                  });
                            },
                            separatorBuilder: (context, index) {
                              return const Column(
                                children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Divider(
                                    color: Color(0xFFdcdcdc),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  )),
              Flexible(
                flex: 1,
                child: SizedBox(
                  width: 380,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedFridge != null) {
                        Navigator.pop(
                            context, selectedFridge!['id']); // 선택된 냉장고 정보 전달
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF449C4A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                    child: Text(
                      '변경하기',
                      style: TextStyle(
                        fontSize: 20 * scaleWidth(context),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class getFrigerList {
  final int id;
  final String name;
  final int inventory_count;
  final int user_count;

  getFrigerList(
      {required this.id,
      required this.name,
      required this.inventory_count,
      required this.user_count});

  factory getFrigerList.fromJson(Map<String, dynamic> json) {
    return getFrigerList(
      id: json['id'],
      name: json['name'],
      inventory_count: json["inventory_count"],
      user_count: json['user_count'],
    );
  }
}

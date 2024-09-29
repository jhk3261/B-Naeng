import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Pages/friger/friger_change.dart';
import 'package:frontend/widgets/friger/friger_food.dart';
import 'package:frontend/widgets/friger/plus_btn.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Friger extends StatefulWidget {
  final List<CameraDescription> cameras;

  const Friger({super.key, required this.cameras});

  @override
  State<Friger> createState() => _FrigerState();
}

class _FrigerState extends State<Friger> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int FrigerId = 1;
  List<Map<String, dynamic>> _inventoryList = [];
  final List<Map<String, dynamic>> _currentFriger = [];

  void _refreshInventory() {
    // 데이터 새로 고침 로직
    fetchData();
  }

  //특정 냉장고 데이터 요청 함수
  Future<getFriger?> FetchFriger(int FigerId) async {
    final url = Uri.parse('http://127.0.0.1:8000/frigers/$FrigerId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // JSON이 단일 객체 형태로 반환되는 경우
        Map<String, dynamic> jsonMap =
            jsonDecode(utf8.decode(response.bodyBytes));
        // getFriger 객체로 변환
        return getFriger.fromJson(jsonMap);
      } else {
        throw Exception('Failed to load friger');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    return null;
  }

  //특정 냉장고 인벤토리 데이터 가져오는 함수
  Future<List<getInventory>?> FetchInventory(int FrigerId) async {
    final url =
        Uri.parse('http://127.0.0.1:8000/frigers/$FrigerId/inventories');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // JSON이 List 형태로 반환되는 경우
        List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        // 각 리스트 아이템을 getInventory 객체로 변환
        return jsonList.map((json) => getInventory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load inventory');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    return null;
  }

  // 서버에서 데이터를 가져와 _inventoryList를 업데이트하는 함수
  void fetchData() async {
    // FetchInventory 함수 호출
    List<getInventory>? InventoryList = await FetchInventory(FrigerId);

    getFriger? currentFriger = await FetchFriger(FrigerId); // 현재 냉장고 데이터 가져오기

// 기존의 내용 업데이트
    setState(() {
      _currentFriger.clear(); // 이전 데이터 초기화
      if (currentFriger != null) {
        _currentFriger.add({
          "name": currentFriger.name,
          "unique_code": currentFriger.unique_code,
          "inventory_list": currentFriger.inventory_list,
        });
      }
      _inventoryList.clear();
      if (InventoryList != null && InventoryList.isNotEmpty) {
        _inventoryList = InventoryList.map((inventory) => {
              "id": inventory.id,
              "name": inventory.name,
              "quantity": inventory.quantity,
              "category": inventory.category,
              "date": inventory.date,
              "image": "food_source.png",
            }).toList();
      }
    });
  }

  // 날짜를 "yyyy-MM-dd" 형식으로 변환하는 함수
  String getFormattedDate(DateTime? date) {
    if (date != null) {
      return DateFormat('yyyy-MM-dd').format(date);
    }
    return 'No Date';
  }

  String selectedCategory = "전체보기";
  List categories = ["전체보기", "육류", "소스", "유제품", "채소및과일", "음료", "기타"];

  List<Map<String, dynamic>> filterInventory(String category) {
    if (category == "전체보기") {
      return _inventoryList;
    }
    return _inventoryList
        .where((item) => item['category'] == category)
        .toList();
  }

  // 날짜 차이 계산 함수
  int calculateRemainingDays(DateTime date) {
    final now = DateTime.now();

    // 시간 부분을 00:00:00으로 설정
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    // 날짜 차이 계산
    var difference = targetDate.difference(today).inDays;

    // 차이가 음수인 경우, 즉 과거 날짜인 경우 0 반환
    if (difference < 0) {
      difference = 0;
    }

    return difference;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedCategory = categories[_tabController.index];
      });
    });
    fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        floatingActionButton: SizedBox(
          child: PlusBtn(
            cameras: widget.cameras,
            currentFridgeId: FrigerId,
            onFoodAdded: _refreshInventory, // 콜백 함수 전달
          ),
        ),
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.white,
          // shadowColor: Colors.black,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF232323),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _currentFriger.isNotEmpty
                        ? _currentFriger[0]['name'] ??
                            'No Name' // 첫 번째 아이템의 name
                        : 'No Friger Available',
                    style: const TextStyle(
                      fontSize: 28,
                      color: Color(0xFF449C4A),
                      fontFamily: 'GmarketSansBold',
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  const Text(
                    "의 냉장고",
                    style: TextStyle(
                      fontFamily: 'GmarketSansBold',
                      fontSize: 24,
                      color: Color(0xFF8EC96D),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      // FrigerChange 화면으로 이동하고 선택한 냉장고 ID를 받아옵니다.
                      final selectedFridgeId = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                FrigerChange(currentFridgeId: FrigerId)),
                      );
                      // 선택한 냉장고 ID가 null이 아니면 FrigerId를 업데이트합니다.
                      if (selectedFridgeId != null) {
                        setState(() {
                          FrigerId = selectedFridgeId; // 선택한 냉장고 ID로 업데이트
                          _currentFriger.clear(); // 현재 냉장고 리스트 초기화
                          fetchData(); // 새로운 냉장고 데이터 가져오기
                        });
                      }
                    },
                    color: const Color(0xFFCBCBCB),
                    icon: const Icon(Icons.repeat_rounded),
                  ),
                ],
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  tabAlignment: TabAlignment.start,
                  tabs: categories
                      .map((category) => Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 1.0), // 간격 조절
                            child: Tab(text: category),
                          ))
                      .toList(),
                  labelStyle: const TextStyle(
                    fontFamily: 'GmarketSansMedium',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF449C4A), // 선택된 탭의 텍스트 크기
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'GmarketSansMedium',
                    fontSize: 16,
                    color: Color(0xFFCBCBCB), // 선택되지 않은 탭의 텍스트 크기
                  ),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: categories.map((category) {
            final filteredInventory = filterInventory(category);
            return SingleChildScrollView(
              child: Container(
                color: const Color(0xffffafafa),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 32,
                        bottom: 12,
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontFamily: 'GmarketSansBold',
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12, left: 12),
                      child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: filteredInventory.length,
                          itemBuilder: (context, index) {
                            final item = filteredInventory[index];
                            final remainingDays =
                                calculateRemainingDays(item['date']);
                            return FrigerFood(
                              num: item['quantity'].toString(),
                              day: remainingDays,
                              imagePath: 'assets/images/${item['image']}',
                              food: item['name'],
                              bgColor: remainingDays < 3
                                  ? const Color(0xFFFDF4F4)
                                  : const Color(0xFFF6FAF6),
                              bdColor: remainingDays < 3
                                  ? const Color(0xFFF28585)
                                  : const Color(0xFFAED3B0),
                              ftColor: remainingDays < 3
                                  ? const Color(0xFFCE2A2A)
                                  : const Color(0xFF449C4A),
                              InventoryId: item['id'],
                              CurrentFrigerId: FrigerId,
                              onFoodAdded: _refreshInventory, // 콜백 함수 전달
                            );
                          },
                          shrinkWrap: true,
                          physics: const ScrollPhysics()),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Divider(color: Color(0xFFE5E5E5), thickness: 1.0),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ));
  }
}

class getFriger {
  final String name;
  final int unique_code;
  final List inventory_list;

  getFriger(
      {required this.unique_code,
      required this.inventory_list,
      required this.name});

  factory getFriger.fromJson(Map<String, dynamic> json) {
    return getFriger(
      name: json['name'],
      unique_code: json["unique_code"],
      inventory_list: json['inventory_list'],
    );
  }
}

class getInventory {
  final int id;
  final String name;
  final int quantity;
  final String category;
  final DateTime? date;

  getInventory(
      {required this.id,
      required this.name,
      required this.quantity,
      required this.category,
      required this.date});

  factory getInventory.fromJson(Map<String, dynamic> json) {
    return getInventory(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      category: json['category'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }
}

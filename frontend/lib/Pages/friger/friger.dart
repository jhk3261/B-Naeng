import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Pages/friger/friger_change.dart';
import 'package:frontend/model/fridge_provider.dart';
import 'package:frontend/widgets/friger/friger_food.dart';
import 'package:frontend/widgets/friger/plus_btn.dart';
import 'package:provider/provider.dart';

class Friger extends StatefulWidget {
  final List<CameraDescription> cameras;

  const Friger({super.key, required this.cameras});

  @override
  State<Friger> createState() => _FrigerState();
}

class _FrigerState extends State<Friger> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String selectedCategory = "전체보기";
  List categories = ["전체보기", "육류", "소스", "유제품", "채소", "음료", "기타"];

  final List<Map<String, dynamic>> _inventoryList = [
    {
      "name": "돼지고기 100g",
      "quantity": 2,
      "category": "육류",
      "date": DateTime(2024, 9, 28),
      "image": "food_pork.png",
    },
    {
      "name": "소고기 100g",
      "quantity": 2,
      "category": "육류",
      "date": DateTime(2024, 9, 27),
      "image": "food_beef.png",
    },
    {
      "name": "굴소스",
      "quantity": 1,
      "category": "소스",
      "date": DateTime(2024, 9, 28),
      "image": "food_source.png",
    },
    {
      "name": "버터",
      "quantity": 2,
      "category": "유제품",
      "date": DateTime(2024, 09, 25),
      "image": "food_butter.png",
    },
    {
      "name": "양파",
      "quantity": 5,
      "category": "채소",
      "date": DateTime(2024, 10, 10),
      "image": "food_onion.png",
    },
    {
      "name": "우유",
      "quantity": 2,
      "category": "음료",
      "date": DateTime(2024, 10, 05),
      "image": "food_milk.png",
    },
    {
      "name": "요거트",
      "quantity": 2,
      "category": "유제품",
      "date": DateTime(2024, 09, 28),
      "image": "food_yogurt.png",
    },
  ];

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
    final difference = date.difference(now).inDays;
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // context를 사용하여 fridgeProvider를 초기화
    final fridgeProvider = Provider.of<FridgeProvider>(context);
    final currentFridge =
        fridgeProvider.fridgeList.firstWhere((fridge) => fridge['iscurrent']);

    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: SizedBox(
          child: PlusBtn(
            cameras: widget.cameras,
          ),
        ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(104.0),
          child: AppBar(
            elevation: 0,
            centerTitle: false,
            surfaceTintColor: Colors.white,
            // shadowColor: Colors.black,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    currentFridge['name'],
                    style: const TextStyle(
                        fontFamily: 'GmarketSansBold',
                        fontSize: 28,
                        color: Color(0xFF449C4A)),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    "냉장고",
                    style: TextStyle(
                      fontFamily: 'GmarketSansBold',
                      fontSize: 24,
                      color: Color(0xFF8EC96D),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FrigerChange()),
                      );
                    },
                    color: const Color(0xFFCBCBCB),
                    icon: const Icon(Icons.repeat_rounded),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(32),
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
        ),
        body: TabBarView(
          controller: _tabController,
          children: categories.map((category) {
            final filteredInventory = filterInventory(category);
            return SingleChildScrollView(
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
                          bgColor: const Color(0xFFFDF4F4),
                          bdColor: const Color(0xFFF28585),
                          ftColor: const Color(0xFFCE2A2A),
                        );
                      },
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Divider(color: Color(0xFFE5E5E5), thickness: 1.0),
                  ),
                ],
              ),
            );
          }).toList(),
        ));
  }
}

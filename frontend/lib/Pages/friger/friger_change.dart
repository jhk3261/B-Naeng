import 'package:flutter/material.dart';
import 'package:frontend/widgets/friger/friger_item.dart';

class FrigerChange extends StatefulWidget {
  const FrigerChange({super.key});

  @override
  State<FrigerChange> createState() => _FrigerChangeState();
}

class _FrigerChangeState extends State<FrigerChange> {
  //냉장고데이터(임시)
  final List<Map<String, dynamic>> fridgeList = [
    {'name': '홍길동', 'user_count': 1, 'iscurrent': true},
    {'name': '이디야 초전점', 'user_count': 4, 'iscurrent': false},
    {'name': '본가', 'user_count': 3, 'iscurrent': false},
  ];

  Map<String, dynamic>? selectedFridge; // 선택된 냉장고 저장

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> currentFridge =
        fridgeList.where((fridge) => fridge['iscurrent'] == true).toList();
    List<Map<String, dynamic>> includedFridges =
        fridgeList.where((fridge) => fridge['iscurrent'] == false).toList();

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
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF232323),
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        frigerItem(
                            frigerData: currentFridge[0],
                            isSelected: selectedFridge == null
                                ? currentFridge[0] == currentFridge[0]
                                : selectedFridge == currentFridge[0],
                            onTap: () {
                              setState(() {
                                selectedFridge =
                                    currentFridge[0]; // 현재 냉장고를 선택 상태로 설정
                              });
                            })
                      ],
                    ),
                  )),
              SizedBox(
                height: 8,
              ),
              Divider(
                color: Color(0xFFDCDCDC),
              ),
              SizedBox(
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
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
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
                                      selectedFridge = friger; //선택된 냉장고 업데이트
                                    });
                                  });
                            },
                            separatorBuilder: (context, index) {
                              return Column(
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
                child: Container(
                  width: 380,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedFridge != null) {
                        setState(() {
                          fridgeList.forEach((friger) {
                            friger['iscurrent'] = false;
                          });
                          selectedFridge!['iscurrent'] = true;
                        });

                        Navigator.pop(context, selectedFridge);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF449C4A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                    child: Text(
                      '변경하기',
                      style: TextStyle(
                        fontSize: 20,
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

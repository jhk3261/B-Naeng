import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/friger/food_counter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class FoodUpdate extends StatefulWidget {
  final int inventoryId;
  final int currentFrigerId;
  final VoidCallback onFoodAdded; // Callback 추가

  const FoodUpdate(
      {super.key,
      required this.inventoryId,
      required this.currentFrigerId,
      required this.onFoodAdded});

  @override
  State<FoodUpdate> createState() => _FoodUpdateState();
}

class _FoodUpdateState extends State<FoodUpdate> {
  final _formKey = GlobalKey<FormState>();
  // 상태 변수 추가
  Inventory? _selectedInventory;

  int get InventoryId => widget.inventoryId; //현재 iventory id
  int get FrigerId => widget.currentFrigerId;

  final List<String> categories = ['육류', '소스', '유제품', '채소', '음료', '기타'];
  String? selectCategory;

  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController buyDateController = TextEditingController();

  int? LocalVariable;
  DateTime selectedDate = DateTime.now();

  late final List<CameraDescription> cameras;

  //날짜선택함수
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd')
            .format(selectedDate); // 날짜를 'YYYY-MM-DD' 형식으로 변환하여 텍스트 필드에 설정
      });
    }
  }

  //id에 맞는 인벤토리 데이터 불러오는 함수
  Future getInventory(int InventoryId, int FrigerId) async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/frigers/${FrigerId}/inventories/${InventoryId}/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // JSON이 단일 객체 형태로 반환되는 경우
        Map<String, dynamic> jsonMap =
            jsonDecode(utf8.decode(response.bodyBytes));

        // Inventory 객체로 변환
        Inventory inventory = Inventory.fromJson(jsonMap);

        setState(() {
          _selectedInventory = inventory; // 상태 변수에 저장
          nameController.text = inventory.name;
          selectCategory = inventory.category;
          LocalVariable = inventory.quantity;
          dateController.text =
              DateFormat('yyyy-MM-dd').format(inventory.date!);
        });
      } else {
        throw Exception('Failed to load friger');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> submitData() async {
    if (_formKey.currentState!.validate()) {
      // 데이터 유효성 검사 통과 시 서버로 전송
      final response = await http.put(
        Uri.parse(
            'http://127.0.0.1:8000/frigers/$FrigerId/inventories/$InventoryId/?'
            'name=${nameController.text}&'
            'quantity=$LocalVariable&'
            'date=${dateController.text}&'
            'category=${selectCategory ?? '기타'}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // 성공적으로 등록된 경우
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('식재료가 수정되었습니다.')),
        );

        widget.onFoodAdded();
        Navigator.pop(context, true);
        // });
      } else {
        // 에러 처리
        print('Error: ${response.statusCode} - ${response.body}'); // 오류 로그 추가
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('식재료 수정에 실패했습니다.')),
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getInventory(InventoryId, FrigerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.black,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "식재료 수정",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Flexible(
            flex: 6,
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 30,
                        left: 30,
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            const InputLabel(
                              content: '식재료명',
                              isVauable: true,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              maxLength: 10,
                              controller: nameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF9F9F9),
                                contentPadding: const EdgeInsets.only(
                                  top: 30,
                                  left: 20,
                                  bottom: 10,
                                ),
                                hintStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFB4B4B4),
                                ),
                                focusColor: const Color(0xFF8EC96D),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF8EC96D),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCBCBCB),
                                  ),
                                ),
                                counterText: '',
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const InputLabel(
                              content: '카테고리',
                              isVauable: true,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                items: categories
                                    .map(
                                      (String item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF232323),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                value: selectCategory,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectCategory = value;
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 65,
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFCBCBCB),
                                    ),
                                    color: const Color(0xFFF9F9F9),
                                  ),
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                  ),
                                  iconSize: 0,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 250,
                                  elevation: 0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: const Color(0xFFF9F9F9),
                                  ),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness:
                                        WidgetStateProperty.all<double>(6),
                                    thumbVisibility:
                                        WidgetStateProperty.all<bool>(false),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 50,
                                  padding: EdgeInsets.only(left: 24, right: 14),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const InputLabel(
                              content: '식재료 개수',
                              isVauable: true,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            FoodCounter(
                              minValue: 0,
                              maxValue: 50,
                              initialValue: LocalVariable ?? 0,
                              onChanged: (value) {
                                LocalVariable = value;
                              },
                            ),
                            //TO DO : count 버튼
                            const SizedBox(
                              height: 20,
                            ),
                            const InputLabel(
                              content: '소비 기한',
                              isVauable: true,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              showCursor: false,
                              controller: dateController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF9F9F9),
                                contentPadding: const EdgeInsets.only(
                                  top: 30,
                                  left: 20,
                                  bottom: 10,
                                ),
                                focusColor: const Color(0xFF8EC96D),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF8EC96D),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCBCBCB),
                                  ),
                                ),
                                counterText: '',
                              ),
                              onTap: () async {
                                DateTime? pickerdate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                    initialDate:
                                        DateTime.parse(dateController.text),
                                    builder: (context, Widget? child) => Theme(
                                          data: ThemeData(
                                            splashColor: Color(0xFF8EC96D),
                                            textTheme: TextTheme(
                                              titleMedium: TextStyle(
                                                  color: Color(0xFF232323)),
                                              labelLarge: TextStyle(
                                                  color: Color(0xFF232323)),
                                            ),
                                            dialogBackgroundColor:
                                                Color(0xFF449C4A),
                                            colorScheme: ColorScheme.light(
                                                    primary: Color(0xff8EC96D),
                                                    onSecondary:
                                                        Color(0xFF232323),
                                                    onPrimary:
                                                        Color(0xFFDCF0D1),
                                                    surface: Color.fromARGB(
                                                        255, 250, 255, 247),
                                                    onSurface:
                                                        Color(0xFF232323),
                                                    secondary:
                                                        Color(0xff232323))
                                                .copyWith(
                                                    primary: Color(0xff449C4A),
                                                    secondary:
                                                        Color(0xff8EC96D)),
                                          ),
                                          child: child ?? Text(""),
                                        ));
                                if (pickerdate != null) {
                                  dateController.text = DateFormat('yyyy-MM-dd')
                                      .format(pickerdate);
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                InputLabel(
                                  content: '구매 일자',
                                  isVauable: false,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  '(선택)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFA6A6A6),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              showCursor: false,
                              controller: buyDateController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF9F9F9),
                                contentPadding: const EdgeInsets.only(
                                  top: 30,
                                  left: 20,
                                  bottom: 10,
                                ),
                                hintText: '식재료 구매 일자를 선택해주세요.',
                                hintStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFB4B4B4),
                                ),
                                focusColor: const Color(0xFF8EC96D),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF8EC96D),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCBCBCB),
                                  ),
                                ),
                                counterText: '',
                              ),
                              onTap: () async {
                                DateTime? pickerdate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2024),
                                  lastDate: DateTime(2100),
                                  initialDate: DateTime.now(),
                                  builder: (context, Widget? child) => Theme(
                                    data: ThemeData(
                                      splashColor: Color(0xFF8EC96D),
                                      textTheme: TextTheme(
                                        titleMedium:
                                            TextStyle(color: Color(0xFF232323)),
                                        labelLarge:
                                            TextStyle(color: Color(0xFF232323)),
                                      ),
                                      dialogBackgroundColor: Color(0xFF449C4A),
                                      colorScheme: ColorScheme.light(
                                              primary: Color(0xff8EC96D),
                                              onSecondary: Color(0xFF232323),
                                              onPrimary: Color(0xFFDCF0D1),
                                              surface: Color.fromARGB(
                                                  255, 250, 255, 247),
                                              onSurface: Color(0xFF232323),
                                              secondary: Color(0xff232323))
                                          .copyWith(
                                              primary: Color(0xff449C4A),
                                              secondary: Color(0xff8EC96D)),
                                    ),
                                    child: child ?? Text(""),
                                  ),
                                );
                                if (pickerdate != null) {
                                  buyDateController.text =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickerdate);
                                }
                              },
                            ),
                          ]),
                    )
                  ],
                )),
          ),
          Flexible(
            flex: 1,
            child: SizedBox(
              width: 380,
              height: 60,
              child: ElevatedButton(
                onPressed: submitData,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF449C4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                child: const Text(
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
    );
  }
}

class InputLabel extends StatelessWidget {
  const InputLabel({
    super.key,
    required this.content,
    required this.isVauable,
  });

  final String content;
  final bool isVauable;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          content,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        isVauable
            ? Container(
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8686),
                  borderRadius: BorderRadius.circular(10),
                ),
              )
            : const SizedBox(
                height: 0,
                width: 0,
              )
      ],
    );
  }
}

class Inventory {
  final int id;
  final String name;
  final int quantity;
  final String category;
  final DateTime? date;

  Inventory(
      {required this.id,
      required this.name,
      required this.quantity,
      required this.category,
      required this.date});

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      category: json['category'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }
}

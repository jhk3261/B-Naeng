import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:frontend/widgets/friger/food_counter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode

class IngredientForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController dateController;
  final TextEditingController buyDateController;
  final String? selectedCategory;
  final int localVariable;
  final List<String> categories;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<String?> onCategoryChanged;

  const IngredientForm({
    super.key,
    required this.nameController,
    required this.dateController,
    required this.buyDateController,
    this.selectedCategory,
    required this.localVariable,
    required this.categories,
    required this.onQuantityChanged,
    required this.onCategoryChanged,
  });

  @override
  _IngredientFormState createState() => _IngredientFormState();
}

class _IngredientFormState extends State<IngredientForm> {
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _buyDateController;
  late String? _selectedCategory;
  late int _localVariable;

  @override
  void initState() {
    super.initState();
    _nameController = widget.nameController;
    _dateController = widget.dateController;
    _buyDateController = widget.buyDateController;
    _selectedCategory = widget.selectedCategory;
    _localVariable = widget.localVariable;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InputLabel(
              content: '식재료명',
              isVauable: true,
            ),
            const SizedBox(height: 10),
            TextFormField(
              maxLength: 10,
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                contentPadding: const EdgeInsets.only(
                  top: 30,
                  left: 20,
                  bottom: 10,
                ),
                hintText: '재료 이름을 입력해주세요 (ex-돼지고기 100g)',
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '식재료명을 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const InputLabel(
              content: '카테고리',
              isVauable: true,
            ),
            const SizedBox(height: 10),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: const Text(
                  '카테고리를 선택해주세요 (없다면 기타 선택)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB4B4B4),
                  ),
                ),
                items: widget.categories
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
                value: _selectedCategory,
                onChanged: (String? value) {
                  setState(() {
                    _selectedCategory = value;
                    widget.onCategoryChanged(value);
                  });
                },
                buttonStyleData: ButtonStyleData(
                  height: 65,
                  padding: const EdgeInsets.only(left: 5, right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBCBCB)),
                    color: const Color(0xFFF9F9F9),
                  ),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF232323),
                  ),
                  iconSize: 24,
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
                    thickness: WidgetStateProperty.all<double>(6),
                    thumbVisibility: WidgetStateProperty.all<bool>(false),
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 50,
                  padding: EdgeInsets.only(left: 24, right: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const InputLabel(
              content: '식재료 개수',
              isVauable: true,
            ),
            const SizedBox(height: 10),
            FoodCounter(
              minValue: 0,
              maxValue: 50,
              initialValue: _localVariable,
              onChanged: (value) {
                setState(() {
                  _localVariable = value;
                  widget.onQuantityChanged(value);
                });
              },
            ),
            const SizedBox(height: 20),
            const InputLabel(
              content: '소비 기한',
              isVauable: true,
            ),
            const SizedBox(height: 10),
            TextFormField(
              showCursor: false,
              controller: _dateController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                contentPadding: const EdgeInsets.only(
                  top: 30,
                  left: 20,
                  bottom: 10,
                ),
                hintText: '식재료의 소비 기한을 설정해주세요.',
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
                DateTime? pickerDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                  builder: (context, Widget? child) => Theme(
                    data: ThemeData(
                      splashColor: const Color(0xFF8EC96D),
                      textTheme: const TextTheme(
                        titleMedium: TextStyle(color: Color(0xFF232323)),
                        labelLarge: TextStyle(color: Color(0xFF232323)),
                      ),
                      dialogBackgroundColor: const Color(0xFF449C4A),
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xff8EC96D),
                        onSecondary: Color(0xFF232323),
                        onPrimary: Color(0xFFDCF0D1),
                        surface: Color.fromARGB(255, 250, 255, 247),
                        onSurface: Color(0xFF232323),
                        secondary: Color(0xff232323),
                      ).copyWith(
                        primary: const Color(0xff449C4A),
                        secondary: const Color(0xff8EC96D),
                      ),
                    ),
                    child: child ?? const Text(""),
                  ),
                );
                if (pickerDate != null) {
                  _dateController.text =
                      DateFormat('yyyy-MM-dd').format(pickerDate);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '소비 기한을 설정하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InputLabel(
                  content: '구매 일자',
                  isVauable: false,
                ),
                SizedBox(width: 4),
                Text(
                  '(선택)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFA6A6A6),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              showCursor: false,
              controller: _buyDateController,
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
                DateTime? pickerDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                  builder: (context, Widget? child) => Theme(
                    data: ThemeData(
                      splashColor: const Color(0xFF8EC96D),
                      textTheme: const TextTheme(
                        titleMedium: TextStyle(color: Color(0xFF232323)),
                        labelLarge: TextStyle(color: Color(0xFF232323)),
                      ),
                      dialogBackgroundColor: const Color(0xFF449C4A),
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xff8EC96D),
                        onSecondary: Color(0xFF232323),
                        onPrimary: Color(0xFFDCF0D1),
                        surface: Color.fromARGB(255, 250, 255, 247),
                        onSurface: Color(0xFF232323),
                        secondary: Color(0xff232323),
                      ).copyWith(
                        primary: const Color(0xff449C4A),
                        secondary: const Color(0xff8EC96D),
                      ),
                    ),
                    child: child ?? const Text(""),
                  ),
                );
                if (pickerDate != null) {
                  _buyDateController.text =
                      DateFormat('yyyy-MM-dd').format(pickerDate);
                }
              },
              validator: (value) {
                // 선택 사항이므로 검증하지 않음
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FoodCreateSwipe extends StatefulWidget {
  final List<Map<String, dynamic>> ingredients; // JSON에서 받은 여러 재료 정보
  final int frigerId; // Add this line

  const FoodCreateSwipe({
    required this.ingredients,
    required this.frigerId, // Add this line
    super.key,
  });

  @override
  State<FoodCreateSwipe> createState() => _FoodCreateSwipeState();
}

class _FoodCreateSwipeState extends State<FoodCreateSwipe> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController(); // 페이지 컨트롤러
  int _currentPage = 0;

  final List<String> categories = ['육류', '소스', '유제품', '채소및과일', '음료', '기타'];
  List<String?> selectedCategories = [];
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> dateControllers = [];
  List<TextEditingController> buyDateControllers = [];
  List<int> localVariables = [];

  @override
  void initState() {
    super.initState();
    for (var ingredient in widget.ingredients) {
      nameControllers
          .add(TextEditingController(text: ingredient['name'] ?? ''));
      dateControllers
          .add(TextEditingController(text: ingredient['expiryDate'] ?? ''));
      buyDateControllers
          .add(TextEditingController(text: ingredient['buyDate'] ?? ''));
      selectedCategories.add(ingredient['category']);
      localVariables.add(ingredient['quantity'] ?? 0); // 초기 카운터 값 설정
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String baseUrl =
          'http://127.0.0.1:8000/frigers/${widget.frigerId}/inventories/';

      for (int i = 0; i < widget.ingredients.length; i++) {
        final Map<String, dynamic> data = {
          "friger_id": widget.frigerId,
          "name": nameControllers[i].text,
          "quantity": localVariables[i],
          "date": dateControllers[i].text,
          "category": selectedCategories[i] ?? '',
        };

        try {
          final response = await http.post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(data),
          );
        } catch (e) {}
      }

      // Show a success message after all ingredients are registered
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('식재료가 성공적으로 등록되었습니다!')),
      );
      Navigator.pop(context);
    }
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
          "식재료 등록",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PreferredSize(
            preferredSize: const Size.fromHeight(20.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Text(
                "${_currentPage + 1}/${widget.ingredients.length}",
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF57AE5D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 6,
            child: Form(
              key: _formKey,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.ingredients.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return IngredientForm(
                    nameController: nameControllers[index],
                    dateController: dateControllers[index],
                    buyDateController: buyDateControllers[index],
                    selectedCategory: selectedCategories[index],
                    localVariable: localVariables[index],
                    categories: categories,
                    onQuantityChanged: (value) {
                      setState(() {
                        localVariables[index] = value;
                      });
                    },
                    onCategoryChanged: (value) {
                      setState(() {
                        selectedCategories[index] = value;
                      });
                    },
                  );
                },
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentPage > 0
                      ? TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text(
                            "이전",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF8EC96D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  _currentPage < widget.ingredients.length - 1
                      ? TextButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              // Optional: Provide feedback to the user
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('모든 필수 필드를 채워주세요')),
                              );
                            }
                          },
                          child: const Text(
                            "다음",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF8EC96D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8EC96D),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "등록하기",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
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
            fontWeight: FontWeight.bold,
            color: Color(0xFF232323),
          ),
        ),
        const SizedBox(width: 5),
        isVauable
            ? Container(
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8686),
                  borderRadius: BorderRadius.circular(10),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

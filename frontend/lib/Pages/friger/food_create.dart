import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:frontend/widgets/friger/confirm_btn.dart';
import 'package:frontend/widgets/friger/food_counter.dart';
import 'package:intl/intl.dart';

class FoodCreate extends StatefulWidget {
  const FoodCreate({super.key});

  @override
  State<FoodCreate> createState() => _FoodCreateState();
}

class _FoodCreateState extends State<FoodCreate> {
  final _formKey = GlobalKey<FormState>();

  final List<String> categories = ['육류', '소스', '유제품', '채소', '음료', '기타'];
  String? selectCategory;

  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController buyDateController = TextEditingController();

  int LocalVariable = 0;

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
                                hint: const Text(
                                  '카테고리를 선택해주세요 (없다면 기타 선택)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFB4B4B4),
                                  ),
                                ),
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
                                DateTime? pickerdate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                    initialDate: DateTime.now(),
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
          const Flexible(
            flex: 1,
            child: ConfirmBtn(content: '등록하기'),
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

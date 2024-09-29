import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/Pages/login/signup_complete.dart';
import 'package:frontend/widgets/login/signup_inputForm.dart';
import 'package:frontend/widgets/login/signup_termsForm.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignupPage1 extends StatefulWidget {
  final String username;
  final String email;

  const SignupPage1({
    super.key,
    required this.username,
    required this.email,
  });

  @override
  _SignupPage1 createState() => _SignupPage1();
}

class _SignupPage1 extends State<SignupPage1> {
  bool isCheckedAll = false;
  bool isCheckedFirstForm = false;
  bool isCheckedSecondForm = false;

  bool validNickname = false;
  bool validBirthday = false;
  bool validGender = false;
  bool validRecommender = false;
  bool validLocation = false;

  final nicknameController = TextEditingController();
  final birthdayController = TextEditingController();
  final recommenderController = TextEditingController();

  int gender = -1; // 성별 선택 값 (0: 남성, 1: 여성)

  // checkbox 전체 값 변경
  void updateAllCheckbox(bool newValue) {
    setState(() {
      isCheckedAll = newValue;
      isCheckedFirstForm = newValue;
      isCheckedSecondForm = newValue;
    });
  }

  // checkbox 개별 값에 따른 전체 값 변경
  void updateCheckbox(bool? newValue, String form) {
    setState(() {
      if (form == 'first') {
        isCheckedFirstForm = newValue ?? false;
      } else if (form == 'second') {
        isCheckedSecondForm = newValue ?? false;
      }

      if (!isCheckedFirstForm || !isCheckedSecondForm) {
        isCheckedAll = false;
      } else if (isCheckedFirstForm && isCheckedSecondForm) {
        isCheckedAll = true;
      }
    });
  }

  // 닉네임 유효성 검증
  void updateNicknameValidState(bool isValid) {
    setState(() {
      validNickname = isValid;
    });
  }

  // 생년월일 유효성 검증
  void updateBirthdayValidState(bool isValid) {
    setState(() {
      validBirthday = isValid;
    });
  }

  // 추천인 유효성 검증
  void updateRecommenderValidState(bool isValid) {
    setState(() {
      validRecommender = isValid;
    });
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthdayController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        updateBirthdayValidState(true);
      });
    }
  }

  final TextEditingController _locationController = TextEditingController();
  String _currentAddress = '';
  bool _isLoading = false;

  // 위치 초기화 후 위치 정보 불러오기
  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // 초기화 시 현재 위치를 가져옴
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = "위치 서비스가 비활성화되어 있습니다.";
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = "위치 권한이 거부되었습니다.";
            _isLoading = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String address =
          await _getAddressFromLatLng(position.latitude, position.longitude);

      setState(() {
        _currentAddress = address;
        _locationController.text = _currentAddress; // 주소를 TextFormField에 설정
        _isLoading = false; // 로딩 중지
      });
    } catch (e) {
      setState(() {
        _currentAddress = "위치 정보를 가져오는 중 오류 발생: $e";
        _isLoading = false;
      });
    }
  }

  Future<String> _getAddressFromLatLng(
      double latitude, double longitude) async {
    String apiKey = "YOUR_GOOGLE_MAPS_API_KEY"; // 여기에 Google Maps API 키 입력
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'][0]['formatted_address']; // 주소 반환
    } else {
      throw Exception('주소를 불러오는 데 실패했습니다.');
    }
  }

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // 서버에 유저 정보 전송
  Future<bool> signupInfoToServer(
    String username,
    String email,
    String nickname,
    DateTime birth,
    int gender,
    String? recommender,
    String location,
  ) async {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/login');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'nickname': nickname,
          'birth': birth.toIso8601String(),
          'gender': gender,
          'recommender': recommender,
          'location': location,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await storage.write(
            key: 'access_token', value: responseData['access_token']);
        String accessToken = responseData['access_token'];
        print('Access Token: $accessToken');

        // 요청 성공 시 true 반환
        return true;
      } else {
        print('Failed to send user info: ${response.body}');
        return false; // 실패 시 false 반환
      }
    } catch (e) {
      print('Error occurred during signup: $e');
      return false; // 오류 발생 시 false 반환
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'access_token');
  }

  Future<void> verifyToken(String token) async {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/verify-token');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 토큰을 Authorization 헤더에 추가
        },
        body: jsonEncode({
          'token': token, // 서버에서 토큰을 받을 수 있도록
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Token is valid for user: ${responseData['user']}');
      } else {
        print('Token validation failed: ${response.body}');
      }
    } catch (e) {
      print('Error occurred during token validation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final formTitleFontSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: screenWidth * 0.415,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8EC96D),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.415,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                  ),
                  child: Text(
                    '비냉에 필요한 정보들을\n입력해주세요.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF232323),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: screenWidth * 0.08,
                ),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 닉네임 입력 폼
                        SignupFormBox(
                          formTitle: '닉네임',
                          formGuide: '2~8자 이내로 입력해주세요.',
                          titleFontSize: formTitleFontSize,
                          requiredField: true,
                          fieldController: nicknameController,
                          validInputForm: validNickname,
                          onInputChanged: updateNicknameValidState,
                        ),
                        const SizedBox(height: 20),
                        // 닉네임 입력 폼
                        SignupFormBox(
                          formTitle: '생년월일',
                          formGuide: 'YYYY-MM-DD',
                          titleFontSize: formTitleFontSize,
                          requiredField: true,
                          fieldController: birthdayController,
                          validInputForm: validBirthday,
                          onInputChanged: updateBirthdayValidState,
                          selectDate: selectDate,
                        ),
                        const SizedBox(height: 20),
                        SignupFormBox(
                          formTitle: '동네 위치 찾기',
                          formGuide: '내 위치',
                          titleFontSize: formTitleFontSize,
                          requiredField: true,
                          fieldController: _locationController,
                          validInputForm: validLocation,
                        ),
                        const SizedBox(height: 20),
                        // 성별 선택 폼
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '성별',
                              style: TextStyle(
                                fontSize: formTitleFontSize,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF232323),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Color(0xffFF8686),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  gender = 0;
                                  validGender = true;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: screenWidth * 0.16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: gender == 0
                                        ? const Color(0xff8ec960)
                                        : const Color(0xffe5e5e5),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: gender == 0
                                      ? const Color(0xffecf6ea)
                                      : Colors.transparent,
                                ),
                                child: Text(
                                  '남성',
                                  style: TextStyle(
                                    color: const Color(0xff232323),
                                    fontSize: formTitleFontSize,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  gender = 1;
                                  validGender = true;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: screenWidth * 0.16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: gender == 1
                                        ? const Color(0xff8ec960)
                                        : const Color(0xffe5e5e5),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: gender == 1
                                      ? const Color(0xffecf6ea)
                                      : Colors.transparent,
                                ),
                                child: Text(
                                  '여성',
                                  style: TextStyle(
                                    color: const Color(0xff232323),
                                    fontSize: formTitleFontSize,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SignupFormBox(
                          formTitle: '추천인 닉네임',
                          formGuide: '추천인 닉네임을 입력해주세요.',
                          titleFontSize: formTitleFontSize,
                          requiredField: false,
                          fieldController: recommenderController,
                          validInputForm: validRecommender,
                          onInputChanged: updateRecommenderValidState,
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Container(
                width: screenWidth,
                height: 10,
                color: const Color(0xffECF6EA),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: screenWidth * 0.08,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '이용약관 동의',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xffFF8686),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: isCheckedAll,
                          onChanged: (bool? newValue) {
                            setState(() {
                              updateAllCheckbox(newValue ?? false);
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          checkColor: const Color(0xfff9f9f9),
                          activeColor: const Color(0xff8ec960),
                          side: const BorderSide(
                            color: Color(0xffe5e5e5),
                            width: 1,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '약관 전체 동의',
                          style: TextStyle(
                            color: Color(0xff232323),
                          ),
                        )
                      ],
                    ),
                    SignupTermsForm(
                      termsTitle: '이용약관 동의',
                      termsDetail: '내용내용내용...',
                      isChecked: isCheckedFirstForm,
                      onChanged: (bool? newValue) {
                        setState(() {
                          updateCheckbox(newValue, 'first');
                        });
                      },
                    ),
                    SignupTermsForm(
                      termsTitle: '개인정보 수집 및 이용 동의',
                      termsDetail: '내용내용내용...',
                      isChecked: isCheckedSecondForm,
                      onChanged: (bool? newValue) {
                        setState(() {
                          updateCheckbox(newValue, 'second');
                        });
                      },
                    ),
                    const SizedBox(height: 50)
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: (validNickname &&
                        validBirthday &&
                        validGender &&
                        isCheckedAll)
                    ? () async {
                        bool success = await signupInfoToServer(
                          widget.username, // 사용자의 이름
                          widget.email, // 사용자의 이메일
                          nicknameController.text, // 입력한 닉네임
                          DateTime.tryParse(birthdayController.text) ??
                              DateTime.now(), // 생년월일
                          gender, // 선택한 성별
                          recommenderController.text.isEmpty
                              ? null
                              : recommenderController.text, // 추천인 닉네임이 없으면 null
                          _locationController.text, // 입력한 위치 정보
                        );

                        // 서버 요청 성공 시 SignupComplete 페이지로 이동
                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupComplete(
                                cameras: [],
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(screenWidth * 0.84, 50),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  backgroundColor: const Color(0xff449C4A),
                ),
                child: Text(
                  (validNickname &&
                          validBirthday &&
                          validGender &&
                          isCheckedAll)
                      ? '가입하기'
                      : '정보를 입력해주세요',
                  style: TextStyle(
                    color: const Color(0xffffffff),
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/widgets/login/signup_inputForm.dart';
import 'package:frontend/widgets/login/signup_termsForm.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';
// import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart';
// import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final formTitleFontSize = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
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
                        SignupFormBox(
                          formTitle: '닉네임',
                          formGuide: '2~8자 이내로 입력해주세요.',
                          titleFontSize: formTitleFontSize,
                          requiredField: true,
                          fieldController: nicknameController,
                        ),
                        const SizedBox(height: 20),
                        SignupFormBox(
                          formTitle: '생년월일',
                          formGuide: '생년월일 입력하기',
                          titleFontSize: formTitleFontSize,
                          requiredField: true,
                          fieldController: birthdayController,
                        ),
                        const SizedBox(height: 20),
                        // 성별을 라디오 버튼으로 변경
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
                onPressed: () {
                  DateTime birth = DateTime.parse(birthdayController.text);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupPage2(
                        username: widget.username,
                        email: widget.email,
                        nickname: nicknameController.text,
                        birth: birth,
                        gender: gender,
                        recommender: recommenderController.text.isEmpty
                            ? null
                            : recommenderController.text,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(screenWidth * 0.84, 50),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  backgroundColor: const Color(0xff449C4A),
                ),
                child: Text(
                  '다음으로',
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

  @override
  void dispose() {
    nicknameController.dispose();
    birthdayController.dispose();
    recommenderController.dispose();
    super.dispose();
  }
}

class SignupPage2 extends StatefulWidget {
  final String username;
  final String email;
  final String nickname;
  final DateTime birth;
  final int gender;
  final String? recommender;

  const SignupPage2({
    super.key,
    required this.username,
    required this.email,
    required this.nickname,
    required this.birth,
    required this.gender,
    this.recommender,
  });

  @override
  _SignupPage2 createState() => _SignupPage2();
}

class _SignupPage2 extends State<SignupPage2> {
  final locationController = TextEditingController();
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  double latitude = 0.0;
  double longitude = 0.0;
  String? currentAddress;
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _serviceStatusStreamSubscription?.cancel();
    super.dispose();
  }

  // 마커
  void _setUserLocation(double lat, double lng) {
    setState(() {
      latitude = lat;
      longitude = lng;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(lat, lng),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );
      if (_mapController != null) {
        print("Moving camera to new location");
        _mapController?.moveCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
      }
    });
  }

  Future<void> _getCurrentPosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // 위치 서비스가 활성화되었는지 확인
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      // 위치 권한 확인 및 요청
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // 권한이 거부된 경우 처리
          setState(() {
            currentAddress = "위치 권한이 거부되었습니다.";
          });
          return;
        }
      }

      // 영구적으로 권한이 거부된 경우
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }

      // 위치 정보 가져오기
      Position position = await Geolocator.getCurrentPosition();
      _setUserLocation(position.latitude, position.longitude);
      String address =
          await getPlaceAddress(position.latitude, position.longitude);
      setState(() {
        currentAddress = address;
      });
      locationController.text = currentAddress ?? '';
    } catch (e) {
      setState(() {
        currentAddress = "주소를 불러오지 못했습니다. 오류: $e";
      });
      _setUserLocation(0.0, 0.0); // 위치 설정 실패 시 기본값 설정
    }
  }

  String Appkey = "AIzaSyAzFqc4cSwpIZRycZ3qHKrPK8ybOiPVhJ8";

  Future<String> getPlaceAddress(double latitude, double longitude) async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$Appkey&language=ko");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['results'][0]['formatted_address'];
    } else {
      throw Exception('주소를 불러오지 못했습니다.');
    }
  }

  void _onMapCreated(GoogleMapController controlleer) {
    _mapController = controlleer;
  }

  Future<void> signupInfoToServer(
      String username,
      String email,
      String nickname,
      DateTime birth,
      int gender,
      String? recommender,
      String location) async {
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
        String accessToken = responseData['access_token'];
        print('Access Token: $accessToken');
        // 성공적으로 가입한 경우의 추가 로직 작성 가능
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('가입 성공!')),
        );
      } else {
        print('Failed to send user info: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('가입 실패: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error occurred during signup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final formTitleFontSize = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                        borderRadius: BorderRadius.circular(12.0), // 둥글게 설정
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.415,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8EC96D),
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
                    '우리 동네를 입력해주세요.',
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
                    SignupFormBox(
                      formTitle: '동네 위치 찾기',
                      formGuide: '내 위치',
                      titleFontSize: formTitleFontSize,
                      requiredField: true,
                      fieldController: locationController,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: screenWidth,
                      height: 400,
                      child: (latitude != 0.0 && longitude != 0.0)
                          ? GoogleMap(
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(latitude, longitude),
                                zoom: 15,
                              ),
                              markers: _markers,
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        signupInfoToServer(
                          widget.username,
                          widget.email,
                          widget.nickname,
                          widget.birth,
                          widget.gender,
                          widget.recommender,
                          locationController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(screenWidth * 0.84, 50),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        backgroundColor: const Color(0xff449C4A),
                      ),
                      child: Text(
                        '가입하기',
                        style: TextStyle(
                          color: const Color(0xffffffff),
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

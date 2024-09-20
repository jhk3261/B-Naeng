import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/widgets/signup_inputForm.dart';
import 'package:frontend/widgets/signup_termsForm.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend/widgets/user_geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SignupPage1 extends StatefulWidget {
  final String username;
  final String email;

  SignupPage1({
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
  final genderController = TextEditingController();
  final recommenderController = TextEditingController();

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
                        color: Color(0xFF8EC96D),
                        borderRadius: BorderRadius.circular(12.0), // 둥글게 설정
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.415,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15.0,
                  ),
                  child: Text(
                    '비냉에 필요한 정보들을\n입력해주세요.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF232323),
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
                        SizedBox(height: 20),
                        SignupFormBox(
                          formTitle: '생년월일',
                          formGuide: '생년월일 입력하기',
                          titleFontSize: formTitleFontSize,
                          requiredField: true,
                          fieldController: birthdayController,
                        ),
                        SizedBox(height: 20),
                        SignupFormBox(
                          formTitle: '성별',
                          formGuide: '성별 입력하기',
                          titleFontSize: formTitleFontSize,
                          requiredField: true,
                          fieldController: genderController,
                        ),
                        SizedBox(height: 20),
                        SignupFormBox(
                          formTitle: '추천인 닉네임',
                          formGuide: '추천인 닉네임을 입력해주세요.',
                          titleFontSize: formTitleFontSize,
                          requiredField: false,
                          fieldController: recommenderController,
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Container(
                width: screenWidth,
                height: 10,
                color: Color(0xffECF6EA),
              ),
              SizedBox(height: 10),
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
                        SizedBox(width: 5),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
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
                          checkColor: Color(0xfff9f9f9),
                          activeColor: Color(0xff8ec960),
                          side: BorderSide(
                            color: Color(0xffe5e5e5),
                            width: 1,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                        ),
                        SizedBox(width: 8),
                        Text(
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
                    SizedBox(height: 50)
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupPage2(
                        username: widget.username,
                        email: widget.email,
                        nickname: nicknameController.text,
                        birthday: birthdayController.text,
                        gender: genderController.text,
                        recommender: recommenderController.text.isEmpty
                            ? null // 선택적 필드 처리
                            : recommenderController.text,
                      ),
                    ),
                  );
                },
                child: Text(
                  '다음으로',
                  style: TextStyle(
                    color: Color(0xffffffff),
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(screenWidth * 0.84, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  backgroundColor: Color(0xff449C4A),
                ),
              ),
              SizedBox(height: 30),
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
    genderController.dispose();
    recommenderController.dispose();
    super.dispose();
  }
}

class SignupPage2 extends StatefulWidget {
  final String username;
  final String email;
  final String nickname;
  final String birthday;
  final String gender;
  final String? recommender;

  SignupPage2({
    required this.username,
    required this.email,
    required this.nickname,
    required this.birthday,
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
  Set<Marker> _markers = {};
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

  void _setUserLocation(double lat, double lng) {
    setState(() {
      latitude = lat;
      longitude = lng;
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: 'Current Location'),
        ),
      );
      _mapController?.moveCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
    });
  }

  Future<void> _getCurrentPosition() async {
    try {
      Position position = await GeolocatorService.getCurrentPosition();
      _setUserLocation(position.latitude, position.longitude);
      String address =
          await getPlaceAddress(position.latitude, position.longitude);
      setState(() {
        currentAddress = address;
      });
      locationController.text = '$currentAddress';
    } catch (e) {
      _setUserLocation(0.0, 0.0);
      setState(() {
        currentAddress = "주소를 불러오지 못했습니다. : $e";
      });
    }
  }

  String Appkey = "AIzaSyAzFqc4cSwpIZRycZ3qHKrPK8ybOiPVhJ8";

  Future<String> getPlaceAddress(double latitude, double longitude) async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=${Appkey}&language=ko");
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
      String birthday,
      String gender,
      String? recommender,
      String location,
      int exp) async {
    final url = Uri.parse('http://10.0.2.2:8000/login');
    // final url = Uri.parse('http://192.168.200.173:8000/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'nickname': nickname,
        'birthday': birthday,
        'gender': gender,
        'recommender': recommender,
        'location': location,
        "exp": exp,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String accessToken = responseData('access_token');
      print('Access Token : $accessToken');
    } else {
      print('Failed to send user info : ${response.body}');
    }
  }

  // final DatabaseHelper _dbHelper = DatabaseHelper();

  // // Future<void> _saveToDatabase() async {
  // //   await _dbHelper.insertUser(widget.username, widget.email);
  // //   print('User information saved.');
  // // }

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
                        color: Color(0xFF8EC96D),
                        borderRadius: BorderRadius.circular(12.0), // 둥글게 설정
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.415,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color(0xFF8EC96D),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15.0,
                  ),
                  child: Text(
                    '우리 동네를 입력해주세요.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF232323),
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
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: screenWidth,
                      height: 400,
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(latitude, longitude),
                          zoom: 15,
                        ),
                        markers: _markers,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        signupInfoToServer(
                          widget.username,
                          widget.email,
                          widget.nickname,
                          widget.birthday,
                          widget.gender,
                          widget.recommender,
                          locationController.text,
                          300000,
                        );
                      },
                      child: Text(
                        '가입하기',
                        style: TextStyle(
                          color: Color(0xffffffff),
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(screenWidth * 0.84, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        backgroundColor: Color(0xff449C4A),
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

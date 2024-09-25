import 'package:frontend/Pages/chating/chat_room.dart';
import 'package:frontend/Pages/login/signup_complete.dart';
import 'package:frontend/Pages/mypage/mypage.dart';
import 'package:frontend/Pages/recipe/receipe_recommend.dart';
import 'package:frontend/Pages/share/ingrediant/share_ingredient.dart';
import 'package:frontend/Pages/friger/friger.dart';
import 'package:frontend/Pages/share/share_parents.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/Pages/login/google_auth.dart';
import 'package:frontend/Pages/login/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: HomeScreen(cameras: cameras),
      home: SignInPage(),
      // home: SignupComplete(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomeScreen({super.key, required this.cameras});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pages = [
      ReceipeRecommend(cameras: widget.cameras),
      ShareParentScreen(cameras: widget.cameras),
      Friger(cameras: widget.cameras),
      ChatRoom(cameras: widget.cameras),
      MyPage(cameras: widget.cameras),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut); // 애니메이션 효과 추가
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: '레시피',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: '나눔터',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.kitchen),
              label: '냉장고',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: '비냉톡',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '내정보',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xff8ec96d),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

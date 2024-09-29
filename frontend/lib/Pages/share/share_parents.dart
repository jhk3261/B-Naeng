// ignore_for_file: non_constant_identifier_names

import 'package:frontend/Pages/share/ingrediant/WritePostPage.dart';
import 'package:frontend/Pages/share/ingrediant/share_ingredient.dart';
import 'package:frontend/Pages/share/tips/share_tips.dart';
import 'package:frontend/Pages/share/tips/write_tip_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ShareParentScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ShareParentScreen({super.key, required this.cameras});

  @override
  _ShareParentScreenState createState() => _ShareParentScreenState();
}

class _ShareParentScreenState extends State<ShareParentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onEditButtonPressed() async {
    bool? result;
    if (_tabController.index == 0) {
      result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WritePostPage()),
      );
    } else {
      result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WriteTipPage()),
      );
    }

    if (result == true) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: const Padding(
          padding: EdgeInsets.fromLTRB(16, 30, 0, 8),
          child: Text(
            '비냉 나눔터',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              fontFamily: "GmarketSansMedium",
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _onEditButtonPressed, // 버튼 클릭 시 조건에 맞게 페이지 이동
            ),
          ),
          const SizedBox(width: 10),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xff449c4a),
              indicatorWeight: 4.0, // 인디케이터 높이 조절
              labelColor: const Color(0xff449C4A), // 선택된 탭 텍스트 색상
              unselectedLabelColor: Colors.grey, // 선택되지 않은 탭 텍스트 색상
              labelStyle: const TextStyle(
                fontSize: 20, // 선택된 탭 텍스트 크기
                fontWeight: FontWeight.bold,
                fontFamily: 'GmarketSansMedium',
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 20, // 선택되지 않은 탭 텍스트 크기
                fontWeight: FontWeight.bold,
                fontFamily: 'GmarketSansMedium',
              ),
              overlayColor: const WidgetStatePropertyAll(Colors.white),
              tabs: const [
                Tab(text: "재료 나눔"),
                Tab(text: "정보 나눔"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ShareIngredient(cameras: widget.cameras),
          ShareTips(cameras: widget.cameras),
        ],
      ),
    );
  }
}

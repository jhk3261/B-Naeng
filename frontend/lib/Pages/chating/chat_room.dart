import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/chating/chat_element.dart';

class ChatRoom extends StatelessWidget {
  final List<CameraDescription> cameras;

  const ChatRoom({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "채팅",
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: "GmarketSansMedium",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "관리",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                ChatElement(
                  otherUserName: "이민재",
                  otherUserProfilePath: "assets/images/random_image.jpeg",
                  lastChatText: "안녕하세요, 지금 고기 나눔 가능하세요?",
                  lastChatTime: "18:06",
                  numUnreadMsg: 4,
                ),
                ChatElement(
                  otherUserName: "신지아",
                  otherUserProfilePath: "assets/images/default_profile.png",
                  lastChatText: "쿠키 남은거 받을 수 있을까요??",
                  lastChatTime: "21:06",
                  numUnreadMsg: 2,
                ),
                ChatElement(
                  otherUserName: "서지원",
                  otherUserProfilePath: "assets/images/default_profile.png",
                  lastChatText: "지금 등갈비를 하려하는데 갈비가 없어서요...ㅎㅎ 지금 가지러 가도 될까요?",
                  lastChatTime: "09:06",
                  numUnreadMsg: 0,
                ),
                ChatElement(
                  otherUserName: "강지희",
                  otherUserProfilePath: "assets/images/default_profile.png",
                  lastChatText: "잠시 뒤 아파트 입구에서 뵐게요~!",
                  lastChatTime: "18:06",
                  numUnreadMsg: 4,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

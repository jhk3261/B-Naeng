import 'package:flutter/material.dart';

class ChatElement extends StatelessWidget {
  final String otherUserName;
  final String otherUserProfilePath;
  final String lastChatText;
  final String lastChatTime;
  final int numUnreadMsg;

  const ChatElement({
    super.key,
    required this.otherUserName,
    required this.otherUserProfilePath,
    required this.lastChatText,
    required this.lastChatTime,
    required this.numUnreadMsg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 69,
                height: 69,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EFE8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9), // 원하는 반경을 지정
                    child: Image.asset(
                      otherUserProfilePath,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
                height: 69,
              ),
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUserName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      lastChatText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(lastChatTime),
              const SizedBox(
                height: 7,
              ),
              if (numUnreadMsg != 0)
                Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                      color: const Color(0xFF449C4A),
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                      child: Text(
                    numUnreadMsg.toString(),
                    style: const TextStyle(color: Colors.white),
                  )),
                )
            ],
          ),
        ],
      ),
    );
  }
}

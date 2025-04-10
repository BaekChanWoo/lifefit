import 'package:flutter/material.dart';

class TimeDisplay extends StatelessWidget {
  final TextEditingController controller;

  const TimeDisplay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container( // TextField 대신 Container 사용
      decoration: BoxDecoration( // 상자 모양 설정
        border: Border.all(
          color: Colors.grey, // 테두리 색상
          width: 1.0, // 테두리 두께
        ),
        borderRadius: BorderRadius.circular(5.0), // 테두리 모서리 둥글게
        color: Colors.white, // 배경색
      ),
      padding: const EdgeInsets.all(8.0), // 내부 여백
      child: Text( // Text 위젯으로 텍스트 표시
        controller.text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
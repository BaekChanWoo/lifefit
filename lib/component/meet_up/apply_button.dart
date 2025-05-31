import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../const/colors.dart';

class ApplyButton extends StatelessWidget {
  final bool isApplied;
  final bool isFull; // ← 추가
  final VoidCallback onPressed;

  const ApplyButton({
    Key? key,
    required this.isApplied,
    required this.isFull, // ← 추가
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 상태에 따라 버튼 텍스트 결정
    String buttonText;
    if (isFull) {
      buttonText = '마감';
    } else if (isApplied) {
      buttonText = '신청 완료';
    } else {
      buttonText = '신청';
    }

    return ElevatedButton(
      onPressed: isFull ? null : onPressed, // 마감이면 비활성화
      style: ElevatedButton.styleFrom(
        backgroundColor: isFull ? Colors.grey : (isApplied ? Colors.grey : PRIMARY_COLOR),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

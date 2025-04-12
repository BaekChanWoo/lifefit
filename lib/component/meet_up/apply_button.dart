import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';

/// 신청 버튼 위젯  ui만 담당하는 역할임
class ApplyButton extends StatelessWidget {
  final bool isApplied; // 신청 여부 (true면 이미 신청함)
  final VoidCallback onPressed;

  const ApplyButton({
    Key? key,
    required this.isApplied,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isApplied ? null : onPressed, // 이미 신청했으면 비활성화
      style: ElevatedButton.styleFrom(
        backgroundColor: isApplied ? Colors.grey : PRIMARY_COLOR,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        isApplied ? '신청 완료' : '신청',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

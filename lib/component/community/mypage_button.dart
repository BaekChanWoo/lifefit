import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';

// 마이페이지 버튼 커스텀 스타일
class MyPageButton extends StatefulWidget {
  final void Function()? onTap;
  final String label;
  const MyPageButton({super.key, required this.label, this.onTap});

  @override
  State<MyPageButton> createState() => _MyPageButtonState();
}

class _MyPageButtonState extends State<MyPageButton> {
  bool _isTapped = false; // 버튼이 눌린 상태인지 추적

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isTapped = true), // 누를 때 눌림 상태로 전환
      onTapUp: (_) => setState(() => _isTapped = false), // 뗼 떼 원래 상태로
      onTapCancel: () => setState(() => _isTapped = false), // 탭 취소 시 원래 상태로
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 38.0,
        decoration: BoxDecoration(
          color: _isTapped ? PRIMARY_COLOR.withAlpha(50) : Colors.white,
          border: Border.all(
            color: PRIMARY_COLOR,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2), // 그림자 아래로 2 이동
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15.0,
              color: PRIMARY_COLOR,
            ),
          ),
        ),
      ),
    );
  }
}



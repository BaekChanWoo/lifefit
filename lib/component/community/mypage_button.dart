import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';

// 마이페이지 버튼 커스텀 스타일
class MyPageButton extends StatelessWidget {
  final void Function()? onTap;
  final String label;
  const MyPageButton({super.key , required this.label , this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: PRIMARY_COLOR,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w400 , fontSize: 18),
          ),
        ),
      ),
    );
  }
}



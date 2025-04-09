import 'package:flutter/material.dart';
import 'package:lifefit/component/community/mypage_button.dart';

// 마이페이지 버튼
class Buttons extends StatelessWidget {
  const Buttons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              //flex: 4,
              child: MyPageButton(onTap:(){} ,label: '프로필 수정'),
          ),
          const SizedBox(width: 20.0,),
          Expanded(
            //flex: 4,
            child: MyPageButton(onTap:(){} ,label: '프로필 공유'),
          ),
        ],
      ),
    );
  }
}

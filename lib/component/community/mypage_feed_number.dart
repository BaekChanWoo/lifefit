import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';
import 'package:get/get.dart';
import 'package:lifefit/controller/feed_controller.dart';

class MyPageFeedNumber extends StatelessWidget {
  const MyPageFeedNumber({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedController feedController = Get.find<FeedController>();
    int myPostCount = feedController.feedList.length; // 동적 데이터 반영

    return Row(
      mainAxisSize: MainAxisSize.min, // Row가 필요한 만큼 공간 차지
      children: [
        Icon(
          Icons.grid_view_rounded,
          color: PRIMARY_COLOR,
          size: 18.0, // 아이콘 크기 축소
        ),
        const SizedBox(width: 6.0), // 간격 축소
        Text(
          '$myPostCount',
          style: const TextStyle(
            fontSize: 16.0, // 약간 작게
            fontWeight: FontWeight.bold,
            color: PRIMARY_COLOR,
          ),
        ),
        const SizedBox(width: 4.0),
        Text(
          '게시물',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700], // 더 진한 회색
          ),
        ),
      ],
    );

  }
}

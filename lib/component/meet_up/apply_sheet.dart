import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/model/meetup_model.dart';

/// 신청 바텀시트: 함께 운동하기 버튼을 누르면 currentPeople 증가
class ApplySheet extends StatelessWidget {
  final Post post;             // 선택한 게시글
  final VoidCallback onApplied; // 인원 증가 -> setState 처리 콜백

  const ApplySheet({
    Key? key,
    required this.post,
    required this.onApplied,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리명
          Text('🏃 ${post.category}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          // 위치
          Text(post.location, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),

          // 날짜,시간
          Text(post.dateTime, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),
          // 정원
          Text(
              '현재 인원: ${post.currentPeople}명 / ${post.maxPeople}명',
              style: const TextStyle(fontSize: 14, color: Colors.grey),),


          const SizedBox(height: 20),

          // 함께 운동하기 버튼 (신청 버튼)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // 정원 초과가 아닐 때만 인원 증가
                if (post.currentPeople < post.maxPeople) {
                  post.currentPeople += 1;
                  onApplied(); // 외부 setState() 호출
                }
                Navigator.pop(context); // 바텀시트 닫기
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '함께 운동하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
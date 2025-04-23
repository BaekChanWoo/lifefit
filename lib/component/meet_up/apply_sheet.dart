import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/model/meetup_model.dart';

// 신청 시트: 함께 운동하기 or 신청 취소
class ApplySheet extends StatelessWidget {
  final Post post;             // 선택한 게시글
  final VoidCallback onApplied; // 인원 변경 -> setState 처리 콜백

  const ApplySheet({
    Key? key,
    required this.post,
    required this.onApplied,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String currentUser = '차예빈'; //현재 사용자 이름 하드코딩
    final bool isApplied = post.applicants.contains(currentUser); // 신청 여부 확인

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
          Text('${post.category}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(post.location, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(post.dateTime, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),
          Text(
            '현재 인원: ${post.currentPeople}명 / ${post.maxPeople}명',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // 신청, 신청 취소 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (isApplied) {
                  //신청 취소 처리
                  post.applicants.remove(currentUser);
                  post.currentPeople--;
                } else {
                  //신청 처리
                  if (post.currentPeople < post.maxPeople) {
                    post.applicants.add(currentUser);
                    post.currentPeople++;
                  }
                }

                onApplied(); //상태 업데이트
                Navigator.pop(context); // 시트 닫기
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isApplied ? Colors.red : PRIMARY_COLOR,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isApplied ? '신청 취소' : '함께 운동하기',
                style: const TextStyle(
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

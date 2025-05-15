import 'package:flutter/material.dart';
import 'package:lifefit/component/community/mypage_button.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/component/community/mypage_feed_number.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

// 커뮤니티 마이페이지
class _MyPageState extends State<MyPage> with SingleTickerProviderStateMixin {
  AnimationController? _controller; // 프로필 사진 확대 애니메이션
  Animation<double>? _scaleAnimation; // 확대 효과를 위한 애니매이션 값

  @override
  void initState() {
    super.initState();
    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    // 애니메이션 설정
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
    );
    print('초기화: ${_scaleAnimation != null}'); // 초기화 확인
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 초기화 되지 않은 경우 로딩 표시
    if (_scaleAnimation == null || _controller == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26), // 부드로운 회색 그림자
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()), // 중앙에 로딩 인디케이터
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 사진과 텍스트
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 사진
              GestureDetector(
                onTapDown: (_) => _controller!.forward(), // 누를 때 확대 시작
                onTapUp: (_) => _controller!.reverse(), // 뗼 떼 원래 크기로
                onTapCancel: () => _controller!.reverse(), // 취소 시 원래 크기로
                child: AnimatedBuilder(
                  animation: _scaleAnimation!,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation!.value, // 현재 확대 비율 적용
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // 원형 모양
                      gradient: LinearGradient(
                        colors: [
                          PRIMARY_COLOR,
                          PRIMARY_COLOR.withAlpha(51), // 반 투명 테마 색상
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent, // 배경 투명
                      backgroundImage: AssetImage('assets/img/mypageimg.jpg'),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              // 이름과 소개
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "백찬우",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: PRIMARY_COLOR.withAlpha(26),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        "헬스랑 러닝을 좋아하며 같이 운동 원해요!!",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[800],
                          height: 1.4, // 줄 간격
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis, // 긴 텍스트 생략
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0), // 프로필과 버튼 사이 간격
          // 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: MyPageButton(
                  onTap: () {},
                  label: '프로필 수정',
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: MyPageButton(
                  onTap: () {},
                  label: '게시물 수정',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15.0), // 버튼과 게시물 수 사이 간격
          // 게시물 수 (Container 제거)
          Padding(
            padding: const EdgeInsets.only(left: 4.0), // 약간의 들여쓰기
            child: const MyPageFeedNumber(),
          ),
        ],
      ),
    );
  }
}
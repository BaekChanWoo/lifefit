import 'package:flutter/material.dart';


class MusicTop extends StatefulWidget {
  const MusicTop({super.key});

  @override
  State<MusicTop> createState() => _MusicTopState();
}

class _MusicTopState extends State<MusicTop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '운동 플레이리스트',
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'NanumSquareRound',
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 앱바 아래에 얇은 그림자만 보이도록 Container
          Container(
            height: 2, // 얇게 그림자만 보이도록 설정
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // 오늘의 추천 플레이리스트
          Container(
            margin: const EdgeInsets.only(left: 20),
            padding: const EdgeInsets.only(left: 8),
            width: 290,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF4E3DC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '오늘의 추천 플레이리스트를 감상해 보세요!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NanumSquareRound',
                  ),
                ),
                const SizedBox(width: 5),
                Image.asset(
                  'assets/img/music.png',
                  width: 10,
                  height: 10,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 0),
                Image.asset(
                  'assets/img/fire.png',
                  width: 15,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


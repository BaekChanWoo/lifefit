import 'package:flutter/material.dart';


class MusicTop extends StatefulWidget {
  const MusicTop({super.key});

  @override
  State <MusicTop> createState() => _MusicTopState();
}

class _MusicTopState extends State<MusicTop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.white,

          appBar: AppBar(  //음악플리 수정 필요 뒤로가기
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 4.0,
            shadowColor: Colors.greenAccent,
            shape: const Border(
              bottom: BorderSide(
                color: Colors.transparent,
                width: 0.0,
              ),
            ),

            title: const Padding(
              padding: EdgeInsets.only(left: 0),
              child:
              Text('운동 플레이리스트',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'padauk',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ), // 왼쪽 여백 추가,
            ),
          ),

          body: Column(
            children: [
              const SizedBox(height: 28),
              Container(
                  margin: const EdgeInsets.only(left: 25),
                  padding: const EdgeInsets.only(left: 8),
                  width: 290, // 상자 너비 설정
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
                          ),
                        ),

                        const SizedBox(width: 5,),

                        Image.asset('assets/img/music.png',
                          width: 15,
                          height: 20,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(width: 0,),

                        Image.asset('assets/img/fire.png',
                          width: 15,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ]
                  )
              )
            ],
          )
      );
  }
}
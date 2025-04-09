import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';

class ScheduleCard extends StatelessWidget {
  //const ScheduleCard({super.key});

  final int startTime; // 시작 시간
  final int endTime; // 종료 시간
  final String content; // 내용

  const ScheduleCard({
    required this.startTime,
    required this.endTime,
    required this.content,
    Key? key,
}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: PRIMARY_COLOR,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
          padding: const EdgeInsets.all(16.0),
        child: IntrinsicHeight( // 높이를 내부 위젯들의 최대 높이로 설정
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Time(
                  startTime: startTime,
                  endTime: endTime,
              ),
              SizedBox(width: 16.0,),
              _Content(
                  content: content
              ),
              SizedBox(width: 16.0,),
            ],
          ),
        ),
      ),
    );
  }
}



class _Time extends StatelessWidget {
  //const _Time({super.key});
  final int startTime;
  final int endTime;


  const _Time({
    required this.startTime,
    required this.endTime,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: PRIMARY_COLOR,
      fontSize: 16.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text( // 숫자가 두 자릿수가 안 되면 0 으로 채워주기
          '${startTime.toString().padLeft(2,'0')} : 00', style: textStyle,
        ),
        Text(
          '${endTime.toString().padLeft(2,'0')}:00' , style: textStyle.copyWith(
          fontSize: 10.0,
        ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  //const _Content({super.key});

  final String content; // 내용
  const _Content({
    required this.content,
    Key? key,
}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded( // 좌우로 최대한 넓히기
        child: Text(
          content,
        ),
    );
  }
}


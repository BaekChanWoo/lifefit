import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';

class TodayBanner extends StatelessWidget {
  //const TodatBanner({super.key});
  final DateTime selectedDate; // 선택된 날짜
  final int count; // 일정 개수

  const TodayBanner({
    required this.selectedDate,
    required this.count,
    super.key,
});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
    return Container(
      color: PRIMARY_COLOR,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0 , vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text( // 년 월 일 형태로 표시
              '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
              style: textStyle,
            ),
            Row(
              children: [
                Text( // 일정 개수
                  '$count개',
                  style: textStyle,
                ),
                /*
                const SizedBox(width: 8.0,),
                GestureDetector(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 16.0,
                  ),
                ),*/
              ],
            )
          ],
        ),
      ),
    );
  }
}

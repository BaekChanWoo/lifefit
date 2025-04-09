import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lifefit/const/colors.dart';

class MainCalendar extends StatelessWidget {
  //const MainCalendar({super.key});

  final OnDaySelected onDaySelected; // 날짜 선택 시 실행할 함수
  final DateTime selectedDate; // 선택된 날짜

  MainCalendar({
    required this.onDaySelected,
    required this.selectedDate,
});

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_kr',
      onDaySelected: onDaySelected,
      selectedDayPredicate: (date) =>
        date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day,
        focusedDay: DateTime.now(), // 화면에 보여지는 날
        firstDay: DateTime(1900 , 1, 1), // 첫쨰 날
        lastDay: DateTime(2100 , 1 ,1), // 마지막 날
        headerStyle: HeaderStyle( // 화살표, 년도, 월
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19.0,
          ),
        ),
      calendarStyle: CalendarStyle( // 날짜
        isTodayHighlighted: false,
        defaultDecoration: BoxDecoration( // 기본 날짜
          borderRadius: BorderRadius.circular(6.0),
          color: LIGHT_GREY_COLOR,
        ),
        weekendDecoration: BoxDecoration( // 주말 날짜
          borderRadius: BorderRadius.circular(6.0),
          color: LIGHT_GREY_COLOR,
        ),
        selectedDecoration: BoxDecoration( // 선택 날짜
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: PRIMARY_COLOR,
            width: 1.0,
          ),
        ),
        defaultTextStyle: TextStyle( // 기본 글꼴
          fontWeight: FontWeight.w600,
          color: DARK_GREY_COLOR,
        ),
        weekendTextStyle: TextStyle( // 주말 글꼴
          fontWeight: FontWeight.w600,
          color: DARK_GREY_COLOR,
        ),
        selectedTextStyle: TextStyle( // 선택 날짜 글꼴
          fontWeight: FontWeight.w600,
          color: PRIMARY_COLOR,
        ),
      ),
    );
  }
}

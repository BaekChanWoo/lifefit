import 'package:flutter/material.dart';
import 'package:lifefit/component/calendar/main_calendar.dart';
import 'package:lifefit/component/calendar/schedule_card.dart';
import 'package:lifefit/component/calendar/todat_banner.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/component/calendar/schedule_bottom_sheet.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime selectedDate = DateTime.utc( // 선택된 날짜를 관리할 변수
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: PRIMARY_COLOR,
          onPressed: (){
            showModalBottomSheet(
                context: context,
                isDismissible: true,
                builder: (_) => ScheduleBottomSheet(
                  selectedDate: selectedDate, // 선택된 날짜 넘겨주기
                ),
              isScrollControlled: true,
            );
          },
        child: Icon(Icons.add , color: Colors.black,),
      ),
      body: SafeArea(
          child: Column(
            children: [
              MainCalendar(
                selectedDate: selectedDate,
                onDaySelected: (selectedDate , focusedDate) =>
                  onDaySelected(selectedDate, focusedDate, context),
                ),
              SizedBox(height: 10.0,),
              TodayBanner(
                  selectedDate: selectedDate, count: 2
              ),
              SizedBox(height: 10.0,),
              ScheduleCard(
                  startTime: 12, endTime: 13, content: '상체 근력 운동(어깨 등)'
              ),
              ScheduleCard(
                  startTime: 19, endTime: 20, content: '한강 러닝 1시간 코스'
              ),
            ],
          )
      ),
    );
  }

  void onDaySelected(
      DateTime selectedDate ,
      DateTime focusedDate,
      BuildContext context,
      ){
    setState(() {
      this.selectedDate = selectedDate;
    });
  }
}

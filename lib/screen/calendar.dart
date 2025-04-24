import 'package:flutter/material.dart';
import 'package:lifefit/component/calendar/main_calendar.dart';
import 'package:lifefit/component/calendar/schedule_card.dart';
import 'package:lifefit/component/calendar/todat_banner.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/component/calendar/schedule_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifefit/model/schedule_model.dart';

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
                  onDaySelected(selectedDate, focusedDate, context ),
                ),
              SizedBox(height: 10.0,),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                  .collection(
                    'schedule',
                  )
                  .where(
                    'date',
                    isEqualTo:
                    '${selectedDate.year}${selectedDate.month.toString().padLeft(2,'0')}${selectedDate.day.toString().padLeft(2,'0')}',
                  )
                  .snapshots(),
                  builder: (context , snapshot) {
                    return TodayBanner(
                        selectedDate: selectedDate,
                        count: snapshot.data?.docs.length ?? 0, // 데이터가 없는 상태여서 null 이 반환되면 0을 화면에 보여줌
                    );
                  },
              ),
              SizedBox(height: 10.0,),
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                              .collection(
                                'schedule',
                      ) // 현재 선택된 날짜에 해당하는 date 속성을 갖고 있는 일정만 받아옴
                      .where( // 필터링
                        'date',
                        isEqualTo:
                          '${selectedDate.year}${selectedDate.month.toString().padLeft(2,'0')}${selectedDate.day.toString().padLeft(2,'0')}',
                      )
                      .snapshots(),
                      builder: (context , snapshot) {
                        // stream을 가져오는 동안 에러가 났을 때 보여줄 화면
                        if(snapshot.hasError){
                          return Center(
                            child: Text('일정 정보를 가져오지 못했습니다!'),
                          );
                        }
                        // 로딩 중일 때 보여줄 화면
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return Container();
                        }

                        // ScheduleModel로 데이터 매핑하기
                        final schedules = snapshot.data!.docs
                            .map( // 쿼리에서 제공받은 모든 데이터를 리스트로 받아옴
                            (QueryDocumentSnapshot e) => ScheduleModel.fromJson
                              (json: (e.data() as Map<String , dynamic>)),
                        ).toList();

                        return ListView.builder(
                            itemCount: schedules.length,
                            itemBuilder: (context , index) {
                              final schedule = schedules[index];

                              return Dismissible(
                                  key: ObjectKey(schedule.id),
                                  direction: DismissDirection.startToEnd,
                                  onDismissed: (DismissDirection direction){
                                  // 특정 문서 삭제하기
                                    FirebaseFirestore.instance
                                        .collection(
                                      'schedule'
                                    )
                                        .doc(schedule.id) // 특정 문서를 가져옴
                                        .delete();
                                  },
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8.0 , left: 8.0 , right: 8.0,
                                      ),
                                  child: ScheduleCard(
                                      startTime: schedule.startTime,
                                      endTime: schedule.endTime,
                                      content: schedule.content,
                                  ),
                                  ),
                              );
                            }
                        );
                      },
                  ),
              ),
            ],
          )
      ),
    );
  }

  void onDaySelected(
      DateTime selectedDate ,
      DateTime focusedDate,
      BuildContext context
      ){
    setState(() {
      this.selectedDate = selectedDate;
    });
  }
}

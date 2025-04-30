import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart'; // 슬라이더 패키지
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../const/colors.dart';

// 수면 데이터 모델
class SleepModel {
  final String id;
  final DateTime date; // 기록 날짜
  final double sleepHours; // 수면 시간
  final String userId; // 사용자 id

  SleepModel({
    required this.id,
    required this.date,
    required this.sleepHours,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'sleepHours': sleepHours,
    'userId': userId,
  };
}

//수면 시간 기록 화면
class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  double sleepHours = 6.0; // 초기 화면 수면 시간
  late DateTime dateOfNow; // 현재 날짜
  late String dateText; //날짜 텍스트
  late String dayText; //요일 텍스트
  late int selectedDay; // 선택된 요일 인덱스

  final List<String> days = ['일', '월', '화', '수', '목', '금', '토']; // 요일 텍스트 리스트
  List<double> sleepData = List<double>.filled(7, 0); //요일별 수면 시간 저장 리스트

  @override
  void initState() {
    super.initState();
    dateOfNow = DateTime.now(); // 현재 날짜 초기화
    updateDate();
    sleepData[selectedDay] = sleepHours; // 초기 선택 요일의 수면시간
  }

  // 날짜, 요일 업데이트
  void updateDate() {
    dateText = DateFormat('y년 M월 d일', 'ko_KR').format(dateOfNow);
    dayText = DateFormat('E', 'ko_KR').format(dateOfNow);
    selectedDay = dateOfNow.weekday % 7; // 요일을 0~6 인덱스로 바꿈
  }

  //이전 날짜로 이동
  void previousDay() {
    setState(() {
      dateOfNow = dateOfNow.subtract(const Duration(days: 1));
      updateDate();
    });
  }

  //다음 날짜로 이동
  void nextDay() {
    setState(() {
      dateOfNow = dateOfNow.add(const Duration(days: 1));
      updateDate();
    });
  }
  //Firebase에 수면 데이터 저장
  Future<void> saveSleepData() async {
    final sleepModel = SleepModel(
      id: Uuid().v4(),  //랜덤으로 id 생성
      date: dateOfNow,
      sleepHours: sleepHours,
      userId: 'guest', // 임시 사용자 id
    );

    await FirebaseFirestore.instance  //파이어베이스 클라우드 연결
        .collection('sleep')   //sleep 컬ㄹ랙션
        .doc(sleepModel.id)  //
        .set(sleepModel.toJson());  //데이터 쓰기
  }

  //CupertinoPicker
  void _showCupertinoPicker() {
    int initialHour = sleepHours.floor();
    int initialMinute = ((sleepHours - initialHour) * 60).round();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        int selectedHour = initialHour;
        int selectedMinute = initialMinute;

        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text('수면 시간', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //시간 피커
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: initialHour),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int value) {
                          selectedHour = value;
                        },
                        children: List<Widget>.generate(12, (int index) {
                          return Center(child: Text('$index 시간'));
                        }),
                      ),
                    ),
                    //분 피커
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: initialMinute),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int value) {
                          selectedMinute = value;
                        },
                        children: List<Widget>.generate(60, (int index) {
                          return Center(child: Text('$index 분'));
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              //선택 완료 버튼
              TextButton(
                onPressed: () {
                  double selected = selectedHour + selectedMinute / 60.0;
                  setState(() {
                    sleepHours = selected;
                    sleepData[selectedDay] = selected;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('수면시간', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: saveSleepData, // 저장 버튼 추가
            icon: const Icon(Icons.save, color: Colors.black),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // 날짜 및 요일 텍스트와 좌우 이동 아이콘
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: previousDay,
                icon: const Icon(Icons.arrow_left),
              ),
              Column(
                children: [
                  Text(dateText, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(dayText, style: const TextStyle(fontSize: 20)),
                ],
              ),
              IconButton(
                onPressed: nextDay,
                icon: const Icon(Icons.arrow_right),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 원형 슬라이더, 시간 텍스트
          Stack(
            alignment: Alignment.center,
            children: [
              //수면시간 슬라이더
              SizedBox(
                width: 210,
                height: 210,
                child: SleekCircularSlider(
                  min: 0,
                  max: 12,
                  initialValue: sleepHours,
                  appearance: CircularSliderAppearance(
                    angleRange: 360,
                    startAngle: 270,
                    size: 180,
                    customWidths: CustomSliderWidths(
                      trackWidth: 14,
                      progressBarWidth: 16,
                      handlerSize: 5,
                    ),
                    customColors: CustomSliderColors(
                      trackColor: Colors.grey.shade300,
                      progressBarColor: PRIMARY_COLOR,
                      dotColor: Colors.white,
                    ),
                    infoProperties: InfoProperties(
                      mainLabelStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      modifier: (value) => '', //중앙 텍스트 숨김
                    ),
                  ),
                  onChange: (value) {
                    setState(() {
                      sleepHours = value;
                      sleepData[selectedDay] = value;
                    });
                  },
                ),
              ),
              //중앙 시간 텍스트, 클릭 시 다이얼 호출
              GestureDetector(
                onTap: _showCupertinoPicker,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey),
                    Text(
                      '${sleepHours.floor()}시간 ${((sleepHours - sleepHours.floor()) * 60).round()}분',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          //요일 선택 박스
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(days.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: DayBox(
                  label: days[index],
                  selected: index == selectedDay,
                  onTap: () {
                    setState(() {
                      selectedDay = index;
                      sleepHours = sleepData[index]; //선택된 요일에 맞는 수면 시간 불러오기
                    });
                  },
                ),
              );
            }),
          ),

          const SizedBox(height: 25),

          // 수면시간 막대그래프
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final double maxBarHeight = 80; //최대 막대 높이
                final double barHeight = (sleepData[index] / 12) * maxBarHeight; //비율 계산

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${sleepData[index].toStringAsFixed(1)}.', style: const TextStyle(fontSize: 11)),
                    const SizedBox(height: 3),
                    Container(
                      width: 18,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: index == selectedDay ? PRIMARY_COLOR : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// 요일 선택 박스 위젯
class DayBox extends StatelessWidget {
  final String label; //요일 텍스트
  final bool selected; //선택 여부
  final VoidCallback onTap; //클릭 시 동작

  const DayBox({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 35,
        height: 35,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? PRIMARY_COLOR : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

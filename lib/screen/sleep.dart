import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:sleek_circular_slider/sleek_circular_slider.dart'; // 패키지 임포트

import '../const/colors.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  double sleepHours = 6.0; // 초기 수면 시간
  late DateTime dateOfNow; //현재 날짜
  late String dateText; // 화면 날짜
  late String dayText; //화면 요일
  late int selectedDay; //선택한 요일

  final List<String> days = ['일', '월', '화', '수', '목', '금', '토'];
  List<double> sleepData = List<double>.filled(7, 0); // 요일별 수면 시간 저장 (리스트 7개)

  @override
  void initState() {
    super.initState();
    dateOfNow = DateTime.now(); //현재 날짜
    updateDate();
    sleepData[selectedDay] = sleepHours; // 현재 요일 수면 시간 초기화
  }

  void updateDate() {
    dateText = DateFormat('y년 M월 d일', 'ko_KR').format(dateOfNow);
    dayText = DateFormat('E', 'ko_KR').format(dateOfNow);
    selectedDay = dateOfNow.weekday % 7;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('수면시간', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.menu, color: Colors.black),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: previousDay,
                icon: const Icon(Icons.arrow_left),
              ),
              Column(
                children: [
                  Text(
                    dateText,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dayText,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              IconButton(
                onPressed: nextDay,
                icon: const Icon(Icons.arrow_right),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 원형 슬라이더
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
                  //bottomLabelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  mainLabelStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  modifier: (value) {
                    int hour = value.floor();
                    int minute = ((value - hour) * 60).round();
                    return '$hour시간 ${minute.toString().padLeft(2, '0')}분';
                  },
                ),
              ),
              onChange: (value) { //슬라이더를 움직일 때 호출
                setState(() {
                  sleepHours = value;  //값을 현재 값으로 업데이트
                  sleepData[selectedDay] = value;  //수면시간 데이터 업데이트 -> 막대그래프에 사용할거임
                });
              },
              onChangeEnd: (value) {  //슬라이더 조작이 끝났을 때 호출
                setState(() {
                  if (value < 0.5) {
                    sleepHours = 12.0;
                    sleepData[selectedDay] = 12.0;
                  }
                });
              },
            ),
          ),

          const SizedBox(height: 30),

          // 요일 선택 바
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(days.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),  //애니메이션 지속 시간
                curve: Curves.easeInOut, 
                child: DayBox(
                  label: days[index],
                  selected: index == selectedDay,
                  onTap: () {
                    setState(() {
                      selectedDay = index;
                      sleepHours = sleepData[index];
                    });
                  },
                ),
              );
            }),
          ),

          const SizedBox(height: 30),

          //막대그래프
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final double maxBarHeight = 80;
                final double barHeight = (sleepData[index] / 12) * maxBarHeight;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${sleepData[index].toStringAsFixed(1)}h',
                      style: const TextStyle(fontSize: 11),
                    ),
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

// 요일 박스
class DayBox extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

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
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
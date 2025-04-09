import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../const/colors.dart';
import '../widgets/bottom_bar.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  double sleepHours = 6.5; // 초기 수면 시간
  late DateTime dateOfNow; //현재 날짜
  late String dateText; // 화면 날짜
  late String dayText; //화면 요일
  late int selectedDay; //선택한 요일

  final List<String> days = ['일', '월', '화', '수', '목', '금', '토'];


  @override
  void initState() {
    super.initState();
    dateOfNow = DateTime.now(); //현재 날짜
    updateDate();
  }

  //화면에 나타낼 날짜 요일
  void updateDate(){
    dateText = DateFormat('d MMMM yyyy', 'en_US').format(dateOfNow); //날짜 형식
    dayText = DateFormat('EEE', 'en_US').format(dateOfNow); //요일 형식
    selectedDay = dateOfNow.weekday % 7;
  }
  //이전 날짜 화살표
  void previousDay(){
    setState(() {
      dateOfNow = dateOfNow.subtract(const Duration(days: 1));
      updateDate();
    });
  }
  //다음 날짜 화살표
  void nextDay(){
    setState(() {
      dateOfNow = dateOfNow.add(const Duration(days:1));
      updateDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        title: const Text('라이프핏', style: TextStyle(color: Colors.black)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.menu, color: Colors.black),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

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
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    dayText,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                onPressed:nextDay,
                icon: Icon(Icons.arrow_right),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 수면 그래프
          SizedBox(
            width: 250,
            height: 250,
            child: CustomPaint(
              painter: SleepCirclePainter(sleepHours: sleepHours),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.nightlight_round, color: Colors.green),
                    Text("${sleepHours.toStringAsFixed(1)}",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
          // 요일 선택 바
          const SizedBox(height: 30),
          // 요일 선택 바
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(days.length, (index) {
              return DayBox(
                label: days[index],
                selected: index == selectedDay,
                onTap: () {
                  setState(() {
                    selectedDay = index;
                  });
                },
              );
            }),
          ),
        ],
      ),

    );
  }
}
//요일 박스 클릭
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
        width: 36,
        height: 36,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? PRIMARY_COLOR : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          /*border: Border.all(
            color: selected ? Colors.green : Colors.grey.shade300,
            width: 2,
          )*/
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:  Colors.black,
          ),
        ),
      ),
    );
  }
}
// 수면 그래프 그리는 커스텀 페인터
class SleepCirclePainter extends CustomPainter {
  final double sleepHours;

  SleepCirclePainter({required this.sleepHours});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 25.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - strokeWidth;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = PRIMARY_COLOR
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final double sweepAngle = (sleepHours / 12) * 2 * pi;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


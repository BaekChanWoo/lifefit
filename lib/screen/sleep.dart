import 'package:flutter/material.dart';
import 'dart:math';

import '../const/colors.dart';


class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  double sleepHours = 6.5; // 초기 수면 시간


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        title: const Text('라이프핏', style: TextStyle(color: Colors.black)),
        centerTitle: false,
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
          const Text("2 April 2025", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          const Text("Wed", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

          const SizedBox(height: 20),
          // 원형 수면 그래프
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
                    /*Slider(
                      value: sleepHours,
                      min: 0,
                      max: 12,
                      divisions: 24,
                      label: "${sleepHours.toStringAsFixed(1)}h",
                      onChanged: (value) {
                        setState(() {
                          sleepHours = value;
                        });
                      },
                    )*/
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
          // 요일 선택 바
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              DayBox(label: "일"),
              DayBox(label: "월"),
              DayBox(label: "화"),
              DayBox(label: "수", selected: true),
              DayBox(label: "목"),
              DayBox(label: "금"),
              DayBox(label: "토"),
            ],
          ),
        ],
      ),

    );
  }
}

// 원형 수면 그래프 그리는 커스텀 페인터
class SleepCirclePainter extends CustomPainter {
  final double sleepHours;

  SleepCirclePainter({required this.sleepHours});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - strokeWidth;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = Colors.greenAccent
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

// 요일 박스 위젯
class DayBox extends StatelessWidget {
  final String label;
  final bool selected;

  const DayBox({Key? key, required this.label, this.selected = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: selected ? Colors.greenAccent : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );

  }

}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class SleepCard extends StatefulWidget {
  final VoidCallback onTap;
  const SleepCard({super.key, required this.onTap});

  @override
  SleepCardState createState() => SleepCardState();
}

class SleepCardState extends State<SleepCard> {
  double sleepHours = 0.0;
  String statusMessage = '';
  Color backgroundColor = Colors.white;

  //외부에서 호출되어 오늘 수면 데이터를 불러올 수 있게 해줌
  void refreshData() {
    fetchTodaySleep();
  }

  @override
  void initState() {
    super.initState();
    fetchTodaySleep();
  }

  Future<void> fetchTodaySleep() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        sleepHours = 0;
        statusMessage = '로그인이 필요합니다';
        backgroundColor = Colors.grey.shade200;
      });
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 오늘 날짜 수면 데이터를 Firestore에서 조회
    final snapshot = await FirebaseFirestore.instance
        .collection('sleep')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: Timestamp.fromDate(today))
        .get();

    if (snapshot.docs.isEmpty) {
      setState(() {
        sleepHours = 0;
        statusMessage = '수면 기록이 없습니다';
      });
      return;
    }

    //sleepHours 필드가 null일 경우를 대비해 기본값 0을 사용하고, double로 안전하게 변환
    final fetchedHours = (snapshot.docs.first['sleepHours'] ?? 0).toDouble();
    String message;
    if (fetchedHours < 6) {
      message = '😵 피곤해요';
    } else if (fetchedHours <= 8) {
      message = '🙂 괜찮아요';
    } else {
      message = '🌞 에너지 충전 완료';
    }

    setState(() {
      sleepHours = fetchedHours;
      statusMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 180,
        width: MediaQuery.of(context).size.width - 240,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "수면",
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.dark_mode,
                    color: Colors.yellow,
                    size: 20.0,
                  )
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 98,
                width: 95,
                // SleekCircularSlider 위젯
                child: SleekCircularSlider(
                  min: 0,
                  max: 12,
                  initialValue: sleepHours,
                  appearance: CircularSliderAppearance(
                    size: 60,
                    customWidths: CustomSliderWidths(trackWidth: 9, progressBarWidth: 10),
                    customColors: CustomSliderColors(
                      trackColor: Colors.grey.shade100,
                      progressBarColor: Colors.blueAccent,
                      dotColor: Colors.transparent,
                    ),
                    infoProperties: InfoProperties(
                      mainLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      modifier: (value) => '${value.toStringAsFixed(1)}h',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                statusMessage,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SleepCard extends StatefulWidget {
  final VoidCallback onTap;
  const SleepCard({super.key, required this.onTap});


  @override
  SleepCardState createState() => SleepCardState(); //이름을 공개형으로 바꿈
}


class SleepCardState extends State<SleepCard> {
  String todaySleepText = '불러오는 중...';
  String statusMessage = '';
  Color backgroundColor = Colors.white;

  void refreshData() {
    fetchTodaySleep();  // 오늘 수면 다시 불러오기
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
        todaySleepText = '로그인이 필요합니다';
        statusMessage = '';
        backgroundColor = Colors.grey.shade200;
      });
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final snapshot = await FirebaseFirestore.instance
        .collection('sleep')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: Timestamp.fromDate(today))
        .get();

    if (snapshot.docs.isEmpty) {
      setState(() {
        todaySleepText = '수면 기록이 없습니다';
        statusMessage = '';
        //backgroundColor = Colors.grey.shade100;
      });
      return;
    }

    final sleepHours = (snapshot.docs.first['sleepHours'] ?? 0).toDouble();

    String message;
    Color color;
    if (sleepHours < 6) {
      message = '😵 피곤해요';
    } else if (sleepHours <= 8) {
      message = '🙂 괜찮아요';
    } else {
      message = '🌞 에너지 충전 완료';
    }

    setState(() {
      todaySleepText = '🛌 오늘의 잠 : ${sleepHours.toStringAsFixed(1)}시간';
      statusMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 145,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(
                todaySleepText,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                statusMessage,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 전체 수면 기록 화면 - 요일 클릭 시 날짜 이동까지 반영
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../const/colors.dart';

class SleepModel {
  final String id;
  final DateTime date;
  final double sleepHours;
  final String userId;

  SleepModel({
    required this.id,
    required this.date,
    required this.sleepHours,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'sleepHours': sleepHours,
    'userId': userId,
  };
}

class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  double sleepHours = 6.0;
  late DateTime dateOfNow;
  late String dateText;
  late String dayText;
  late int selectedDay;

  final List<String> days = ['일', '월', '화', '수', '목', '금', '토'];
  List<double> sleepData = List<double>.filled(7, 0);

  @override
  void initState() {
    super.initState();
    dateOfNow = DateTime.now();
    updateDate();
    sleepData[selectedDay] = sleepHours;
  }

  void updateDate() {
    dateText = DateFormat('y년 M월 d일', 'ko_KR').format(dateOfNow);
    dayText = DateFormat('E', 'ko_KR').format(dateOfNow);
    selectedDay = dateOfNow.weekday % 7;
    loadSleepDataForSelectedDay();
  }

  void previousDay() {
    setState(() {
      dateOfNow = dateOfNow.subtract(const Duration(days: 1));
      updateDate();
    });
  }

  void nextDay() {
    setState(() {
      dateOfNow = dateOfNow.add(const Duration(days: 1));
      updateDate();
    });
  }

  Future<void> loadSleepDataForSelectedDay() async {
    final String userId = 'guest';
    final DateTime onlyDate = DateTime(dateOfNow.year, dateOfNow.month, dateOfNow.day);
    final snapshot = await FirebaseFirestore.instance
        .collection('sleep')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: onlyDate)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      double loadedHours = data['sleepHours'];
      setState(() {
        sleepHours = loadedHours;
        sleepData[selectedDay] = loadedHours;
      });
    } else {
      setState(() {
        sleepHours = 0;
        sleepData[selectedDay] = 0;
      });
    }
  }

  Future<void> saveSleepData() async {
    final String userId = 'guest';
    final DateTime onlyDate = DateTime(dateOfNow.year, dateOfNow.month, dateOfNow.day);
    final query = await FirebaseFirestore.instance
        .collection('sleep')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: onlyDate)
        .get();

    if (query.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('sleep')
          .doc(query.docs.first.id)
          .update({'sleepHours': sleepHours});
    } else {
      final newModel = SleepModel(
        id: Uuid().v4(),
        date: onlyDate,
        sleepHours: sleepHours,
        userId: userId,
      );
      await FirebaseFirestore.instance
          .collection('sleep')
          .doc(newModel.id)
          .set(newModel.toJson());
    }

    setState(() {
      sleepData[selectedDay] = sleepHours;
    });
  }

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
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: initialMinute),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int value) {
                          selectedMinute = value * 5;
                        },
                        children: List<Widget>.generate(12, (int index) {
                          return Center(child: Text('${index * 5}분'));
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  double selected = selectedHour + selectedMinute / 60.0;
                  setState(() {
                    sleepHours = selected;
                    sleepData[selectedDay] = selected;
                  });
                  await saveSleepData();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('수면 데이터가 저장되었습니다')),
                  );
                },
                child: const Text('확인', style: TextStyle(fontSize: 16)),
              ),
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
          Stack(
            alignment: Alignment.center,
            children: [
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
                      modifier: (value) => '',
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _showCupertinoPicker,
                    child: Column(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey),
                        Text(
                          '${sleepHours.floor()}시간 ${((sleepHours - sleepHours.floor()) * 60).round()}분',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
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
                      final currentWeekday = dateOfNow.weekday % 7;
                      final difference = index - currentWeekday;
                      dateOfNow = dateOfNow.add(Duration(days: difference));
                      updateDate();
                    });
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 25),
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
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

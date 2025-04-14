import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifefit/const/colors.dart';

class TimeDisplay extends StatefulWidget {
  const TimeDisplay({super.key});


  @override
  _TimeDisplayState createState() => _TimeDisplayState();
}

class _TimeDisplayState extends State<TimeDisplay> {
  late DateTime _dateTime; // 현재 날짜
  String _formattedDate = '';

  @override
  void initState() {
    super.initState();
    _updateDate();
  }

  //한국 시각 기준
  void _updateDate() {
    setState(() {
      final now = DateTime.now().toUtc().add(const Duration(hours: 9));
      _dateTime = now;
      _formattedDate = DateFormat('yyyy-MM-dd').format(_dateTime);
    });
  }

  //현재 날짜 화면
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20, top: 400,
      child: Container(
          width: 100,
          height: 35,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Color (0xFF99FF99),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              _formattedDate,
              style: const TextStyle
                (fontSize: 14,
                  fontFamily: 'Padauk',
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
          )
      ),
    );
  }
}
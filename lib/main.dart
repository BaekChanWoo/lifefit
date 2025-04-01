import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/screen/home_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "LifeFit",
      theme: ThemeData(
        useMaterial3: true,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: PRIMARY_COLOR, // 선택 상태 색
          unselectedItemColor: Colors.black, // 비선택 상태색
          backgroundColor: Colors.white, // 배경색
          //elevation: 10.0,
        ),
      ),
      home: HomeScreen(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:lifefit/screen/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get.dart';


void main() async {
  // 플러터 프레임워크가 준비될 때까지 대기
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(); // intl 패키지 초기화
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "LifeFit",
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: HomeScreen(),
      //home: Calendar(),

    ),
  );
}

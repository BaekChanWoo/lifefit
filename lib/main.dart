import 'package:flutter/material.dart';
import 'package:lifefit/screen/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get.dart';
import 'package:lifefit/screen/auth/intro.dart';
//import 'package:lifefit/controller/feed_controller.dart';


void main() async {
  // 플러터 프레임워크가 준비될 때까지 대기
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(); // intl 패키지 초기화
  //Get.put(FeedController());
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "LifeFit",
      theme: ThemeData(
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(fontSize: 16 , color: Colors.grey),
          floatingLabelStyle: TextStyle(fontSize: 10),
          contentPadding: EdgeInsets.all(10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          )
        ),
      ),
      //home: Intro(),
      home: HomeScreen(),
      //home: Calendar(),

    ),
  );
}

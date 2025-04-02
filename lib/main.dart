import 'package:flutter/material.dart';
import 'package:lifefit/screen/home_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "LifeFit",
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: HomeScreen(),
    ),
  );
}

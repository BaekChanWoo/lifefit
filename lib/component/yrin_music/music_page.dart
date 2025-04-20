import 'package:flutter/material.dart';


//재생목록 새 페이지 수정 중
class MusicPage extends StatelessWidget {
  final String categoryImages;

  const MusicPage({super.key, required this.categoryImages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('재생목록'),
      ),
      body: Center(
        child: Image.asset(categoryImages),
      ),
    );
  }
}
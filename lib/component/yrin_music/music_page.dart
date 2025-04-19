import 'package:flutter/material.dart';

class MusicPage extends StatelessWidget {
  final String categoryImages; // 필드 이름을 lowerCamelCase로 변경

  const MusicPage({super.key, required this.categoryImages}); // 생성자 이름 수정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('재생목록'),
      ),
      body: Center(
        child: Image.asset(categoryImages), // 변경된 필드 이름 사용
      ),
    );
  }
}
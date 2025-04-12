import 'package:flutter/material.dart';

class FeedShow extends StatefulWidget {
  final Map item;
  const FeedShow({super.key , required this.item});

  @override
  State<FeedShow> createState() => _FeedShowState();
}

class _FeedShowState extends State<FeedShow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("백찬우 프로필"),
      ),
    );
  }
}

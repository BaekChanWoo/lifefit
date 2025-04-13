import 'package:flutter/material.dart';
import 'package:lifefit/component/community/controller/feed_controller.dart';
import 'package:get/get.dart';

class FeedShow extends StatefulWidget {
  final Map item;
  const FeedShow({super.key, required this.item});

  @override
  State<FeedShow> createState() => _FeedEditState();
}

class _FeedEditState extends State<FeedShow> {
  // FeedController 인스턴스를 가져옵니다.
  final FeedController feedController = Get.find<FeedController>();
  TextEditingController? titleController;
  TextEditingController? nameController;

  void _submit() {
    // 로컬 상태 대신 FeedController를 사용하여 상태 업데이트.
    final updatedItem = {
      ...widget.item,
      'title': titleController!.text,
      'name': nameController!.text,
    };
    // FeedController의 updateData를 호출하여 전역 상태를 업데이트.
    feedController.updateData(updatedItem);
    // 데이터 업데이트 후 이전 화면으로 돌아갑니다.
    Get.back();
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.item['title']);
    nameController = TextEditingController(text: widget.item['name']);
  }

  @override
  void dispose() {
    titleController?.dispose();
    nameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시물 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('수정하기'),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifefit/controller/feed_controller.dart';
import 'package:lifefit/model/feed_model.dart';
import 'package:lifefit/widgets/forms/label_textfield.dart';
import 'package:lifefit/const/colors.dart';

class FeedEdit extends StatefulWidget {
  final FeedModel model;
  const FeedEdit(this.model , {super.key});

  @override
  State<FeedEdit> createState() => _FeedEditState();
}

class _FeedEditState extends State<FeedEdit> {
  final feedController = Get.put(FeedController());
  int? imageId;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String selectedCategory = '요가';

  @override
  void initState(){
    super.initState();
    // 초기화 이후 TextField에 값을 채워주기 위한 작업
    _titleController.text = widget.model.title;
    _nameController.text = widget.model.name;
    _contentController.text = widget.model.content;
    selectedCategory = widget.model.category;
    imageId = widget.model.imageId;
  }

  _submit() async {
    if (_titleController.text.isEmpty || _nameController.text.isEmpty || _contentController.text.isEmpty) {
      Get.snackbar('입력 오류', '모든 필드를 입력해주세요.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final result = await feedController.feedUpdate(
      widget.model.id,
      _titleController.text,
      _contentController.text,
      imageId,
      selectedCategory,
      _nameController.text,
    );
    if (result) {
      Get.back();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물 수정'),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(
              child: ListView(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey , width: 1),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16,),
                  LabelTextfield(
                      label: '제목',
                      hintText: '제목',
                      controller: _titleController
                  ),
                  LabelTextfield(
                      label: '자세한 설명',
                      hintText: '자세한 설명',
                      controller: _contentController,
                      maxLines: 6,
                  ),
                ],
              ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(10.0),
                     ),
                     backgroundColor: PRIMARY_COLOR,
                  ),
                  child: const Text('수정 완료',
                      style: TextStyle(color: Colors.white),
                  ),
              ),
          ),
          ),
        ],
      ),
      ),
    );
  }
}

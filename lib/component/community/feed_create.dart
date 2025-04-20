import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/controller/feed_controller.dart';
import 'package:lifefit/widgets/forms/label_textfield.dart';
import 'package:lifefit/component/community/feed_drop_down.dart';

// 피드 생성 화면
class FeedCreate extends StatefulWidget {
  const FeedCreate({super.key});

  @override
  State<FeedCreate> createState() => _FeedCreateState();
}

class _FeedCreateState extends State<FeedCreate> {
  @override
  Widget build(BuildContext context) {
    final feedController = Get.put(FeedController());
    int? imageId;
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _contentController =TextEditingController();

    // feedList 에 새항목을 추가
    _submit() async{
      final result = await feedController.feedCreate(
        _titleController.text,
        _nameController.text,
        _contentController.text,
        imageId,
      );
      if(result){
        // 성공시 이전 화면으로 돌아감
        Get.back();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("새 게시물")),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20 , vertical: 10),
            child: Column(
              children: [
                Expanded(
                    child: ListView(
                      children: [
                        // 이미지 업로드
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end, // 하단 정렬
                               children: [
                                Container(
                                   width:100,
                                   height: 100,
                                   padding: const EdgeInsets.all(10),
                                   decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: PRIMARY_COLOR, width: 2),
                                   ),
                                   child: const Icon(
                                     Icons.camera_alt_outlined,
                                     color: Colors.grey,
                                     size: 25.0,
                                   ),
                                ),
                                 SizedBox(
                                   width: 133,
                                   child: FeedDropDown(),
                                 )
                             ],
                            ),
                            const SizedBox(height: 16,),
                            // 제목
                            LabelTextfield(
                                label: '제목',
                                hintText: '제목을 입력해주세요.',
                                controller: _titleController,
                            ),
                            // 별명 이름
                            LabelTextfield(
                                label: '별명',
                                hintText: '본인 이름 말고 별병을 입력해주세요.',
                                controller: _nameController,
                            ),
                            // 설명
                            LabelTextfield(
                                label: '설명',
                                hintText: '자세한 설명을 입력하세요',
                                controller: _contentController,
                                maxLines: 10,
                            ),
                      ],
                    ),
                ),
                Padding(
                    padding:const EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: _submit,
                          child: const Text('공유하기'
                          ,style: TextStyle(color: Colors.white),
                          ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          //foregroundColor: PRIMARY_COLOR,
                          backgroundColor: PRIMARY_COLOR,
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

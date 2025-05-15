import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/controller/feed_controller.dart';
import 'package:lifefit/widgets/forms/label_textfield.dart';
import 'package:lifefit/component/community/feed_drop_down.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:lifefit/screen/community.dart';
import 'package:lifefit/const/categories.dart';
import '../../controller/auth_controller.dart';

// 피드 생성 화면
class FeedCreate extends StatefulWidget {
  const FeedCreate({super.key});

  @override
  State<FeedCreate> createState() => _FeedCreateState();
}

class _FeedCreateState extends State<FeedCreate> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // 갤러리에서 이미지 선택
  Future<void> _pickImage() async {
    if (await Permission.photos.request().isGranted) {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else {
      Get.snackbar('권한 오류', '갤러리 접근 권한이 필요합니다.');
    }
  }

  // 서버에 이미지 업로드
  Future<int?> uploadImage(File image) async {
    try {
      var uri = Uri.parse('http://10.0.2.2:3000/file');
      var request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var json = jsonDecode(responseData.body);
        return json['data']; // insertId 반환
      } else {
        Get.snackbar('업로드 에러', '이미지 업로드 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      Get.snackbar('네트워크 에러', '서버 연결 실패: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedController = Get.put(FeedController());
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _contentController =TextEditingController();
    String selectedCategory = feedCategories.first;

    // feedList 에 새항목을 추가
    Future<void> _submit() async {
      if (_titleController.text.isEmpty || _nameController.text.isEmpty || _contentController.text.isEmpty) {
        Get.snackbar('입력 오류', '모든 필드를 입력해주세요.', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      int? imageId;
      if (_image != null) {
        imageId = await uploadImage(_image!);
        if (imageId == null) {
          return;
        }
      }
      final authController = Get.find<AuthController>();
      int userId;
      try {
        userId = authController.currentUserId;
        log('Retrieved userId: $userId', name: 'FeedCreate');
      } catch (e) {
        log('Failed to get currentUserId: $e', name: 'FeedCreate');
        Get.snackbar('인증 오류', '로그인이 필요합니다.', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final result = await feedController.feedCreate(
        _titleController.text,
        _nameController.text,
        _contentController.text,
        imageId,
        selectedCategory,
        userId
      );
      if (result) {
        //Get.back();
        feedController.selectedCategory.value = selectedCategory; // 카테고리 동기화
        await feedController.feedIndex(page: 1, category: selectedCategory); // 피드 목록 새로고침
        Get.snackbar('성공',
            imageId != null ? '게시물과 이미지가 업로드되었습니다.' : '게시물이 업로드되었습니다.',
            snackPosition: SnackPosition.BOTTOM);
        Get.offAll(() => const Community(), arguments: {'initialTab': 0}); // Feed 탭으로 이동
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
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width:100,
                          height: 100,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: PRIMARY_COLOR, width: 2),
                          ),
                          child: _image == null
                              ? const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.grey,
                            size: 25.0,
                          )
                              : Image.file(_image! , fit:  BoxFit.cover,),
                        ),
                      ),
                      SizedBox(
                        width: 133,
                        child: FeedDropDown(
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                      ),
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
                    label: '자세한 설명',
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
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: PRIMARY_COLOR,
                  ),
                  child: const Text('공유하기'
                    ,style: TextStyle(color: Colors.white),
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

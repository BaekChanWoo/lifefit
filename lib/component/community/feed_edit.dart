import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifefit/controller/feed_controller.dart';
import 'package:lifefit/model/feed_model.dart';
import 'package:lifefit/widgets/forms/label_textfield.dart';
import 'package:lifefit/const/colors.dart';
import 'dart:developer';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';


class FeedEdit extends StatefulWidget {
  final FeedModel model;
  const FeedEdit(this.model , {super.key});

  @override
  State<FeedEdit> createState() => _FeedEditState();
}

class _FeedEditState extends State<FeedEdit> {
  final feedController = Get.put(FeedController());
  File? _image;
  final ImagePicker _picker = ImagePicker();
  int? imageId;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();


  @override
  void initState(){
    super.initState();
    // 초기화 이후 TextField에 값을 채워주기 위한 작업
    _titleController.text = widget.model.title;
    _nameController.text = widget.model.name;
    _contentController.text = widget.model.content;
    imageId = widget.model.imageId;
  }

  // 갤러리에서 이미지 선택
  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
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
    } else if (status.isLimited) {
      // iOS에서 제한된 접근
      Get.snackbar(
        '제한된 접근',
        '일부 사진만 접근 가능합니다. 설정에서 "모든 사진"을 허용해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () => openAppSettings(),
          child: Text('설정으로 이동'),
        ),
      );
    } else if (status.isPermanentlyDenied) {
      // 영구 거부
      Get.snackbar(
        '권한 거부',
        '갤러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () => openAppSettings(),
          child: Text('설정으로'),
        ),
      );
    } else {
      // 일반 거부
      Get.snackbar(
        '권한 오류',
        '갤러리 접근 권한이 필요합니다. 다시 시도해주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

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
        return json['data'];
      } else {
        Get.snackbar('업로드 에러', '이미지 업로드 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      Get.snackbar('네트워크 에러', '서버 연결 실패: $e');
      return null;
    }
  }

  Future<void> _submit() async {
    if (feedController.isLoading.value) return;
    if (_titleController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _contentController.text.isEmpty) {
      Get.snackbar('입력 오류', '모든 필드를 입력해주세요.', snackPosition: SnackPosition.BOTTOM);
      return;
    }


    feedController.isLoading.value = true;
    int? newImageId = imageId;

    if (_image != null) {
      newImageId = await uploadImage(_image!);
      if (newImageId == null) {
        feedController.isLoading.value = false;
        return;
      }
      // state에도 반영해두면, 뒤에서 preview나 로컬 상태 갱신 시 편합니다.
      setState(() {
        imageId = newImageId;
      });

    }

    try{
    final result = await feedController.feedUpdate(
      widget.model.id,
      _titleController.text,
      _contentController.text,
      newImageId,
      widget.model.category,
      _nameController.text,
    );

    feedController.isLoading.value = false;

    if (result) {
      Get.snackbar('성공', '게시물이 수정되었습니다.', snackPosition: SnackPosition.BOTTOM);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        log('Navigating to HomeScreen with Community tab', name: 'FeedEdit');
        Get.offAllNamed('/', arguments: {'selectedTab': 3});
      });
    } else {
      Get.snackbar('수정 에러', '게시물 수정에 실패했습니다.', snackPosition: SnackPosition.BOTTOM);
    }
  } catch(e) {
  log('Error in feedUpdate: $e', name: 'FeedEdit');
  feedController.isLoading.value = false;
  Get.snackbar('네트워크 에러', '서버 연결 실패: $e', snackPosition: SnackPosition.BOTTOM);
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물 수정'),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20 , vertical: 10),
      child: Column(
        children: [
          Expanded(
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey , width: 2),
                          ),child: _image != null
                            ? Image.file(_image!, fit: BoxFit.cover)
                            : widget.model.imageId != null && widget.model.imagePath != null
                            ? Image.network(
                          'http://10.0.2.2:3000${widget.model.imagePath}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.grey,
                            size: 25.0,
                          ),
                        )
                            : const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.grey,
                          size: 25.0,
                        ),
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
                    label: '별명',
                    hintText: '본인 이름 말고 별명을 입력해주세요.',
                    controller: _nameController,
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

            child: Obx(
                  () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                  feedController.isLoading.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: PRIMARY_COLOR,
                  ),
                  child: feedController.isLoading.value
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('수정 완료',
                      style: TextStyle(color: Colors.white)),
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
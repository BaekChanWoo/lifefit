import 'package:flutter/material.dart';
import 'package:lifefit/widgets/forms/label_textfield.dart';
import 'package:lifefit/const/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:lifefit/provider/auth_provider.dart';
import 'package:lifefit/shared/global.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lifefit/provider/provider.dart';


// 사용자 프로필 정보를 수정 ( 이름 , 사용자 소개(커뮤니티에 쓰일부분)

class MyEdit extends StatefulWidget {
  const MyEdit({super.key});

  @override
  State<MyEdit> createState() => _MyEditState();
}

class _MyEditState extends State<MyEdit> {
  final _nameController = TextEditingController();
  final _authProvider  = Get.find<AuthProvider>();
  XFile? _pickedImage;
  final _picker = ImagePicker();


  @override
  void initState() {
    super.initState();
    // 이전 화면에서 전달된 현재 이름, (필요시)기존 프로필 이미지 URL 등
    final args = Get.arguments as Map?;
    _nameController.text = args?['name'] ?? '';
    // (선택) args['profileUrl'] 가 있다면 CircleAvatar에 보여줄 수 있습니다.
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 갤러리에서 이미지 선택
  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _pickedImage = image);
      }
    } catch (e, st) {
      print('⚠️ pickImage error: $e');
      print(st);
      Get.snackbar('오류', '이미지 선택 중 오류가 발생했습니다.\n$e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // 선택된 이미지를 서버에 업로드하고, 생성된 파일 ID 반환
  Future<int?> _uploadImage(XFile image) async {
    final uri = Uri.parse('${Global.baseUrl}/file');
    final req = http.MultipartRequest('POST', uri);

    req.headers['Authorization'] = 'Bearer ${Global.accessToken}';
    req.files.add(await http.MultipartFile.fromPath('file', image.path));

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode == 200) {
      final body = json.decode(resp.body);
      if (body['result'] == 'ok') {
        return body['data']['id'] as int;
      }
    }
    return null;
  }

  Future<void> _onSave() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      Get.snackbar('이름을 입력하세요', '',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    int? profileId;
    if (_pickedImage != null) {
      final id = await _uploadImage(_pickedImage!);
      if (id == null) {
        Get.snackbar('업로드 실패', '이미지 업로드 중 오류가 발생했습니다',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      profileId = id;
    }

    final res = await _authProvider.updateProfile(newName, profileId: profileId);
    if (res['result'] == 'ok') {
      Get.back(result: res['data']);
      Get.snackbar('성공', '프로필이 업데이트되었습니다',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('실패', res['message'] ?? '업데이트 중 오류 발생',
          snackPosition: SnackPosition.BOTTOM);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            '프로필 수정',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // 사진 선택 및 미리보기
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: _pickedImage != null
                  ? FileImage(File(_pickedImage!.path))
              // : NetworkImage(args?['profileUrl']) as ImageProvider
                  : null,
              child: _pickedImage == null
                  ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 16,),
          LabelTextfield(
              label: '이름',
              hintText: '이름을 입력해주세요.',
              controller: _nameController,
          ),
          ElevatedButton(
              onPressed:  _onSave,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: PRIMARY_COLOR,
              ),
              child: const Text('저장',
                style: TextStyle(
                    color: Colors.white
                ),
              ),
          ),
        ],
      ),
    );
  }
}

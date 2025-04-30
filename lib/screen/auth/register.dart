import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/controller/auth_controller.dart';
import 'package:lifefit/screen/home_screen.dart';
import 'package:lifefit/widgets/forms/label_textfield.dart';


class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final authController = Get.put(AuthController());
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  final _passConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  String? _nameError; // 닉네임 에러 메시지 저장
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 닉네임 입력 실시간 유효성 검사
    _nameController.addListener(() {
      setState(() {
        _nameError = authController.validateName(_nameController.text);
      });
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _passController.dispose();
    _passConfirmController.dispose();
    _nameController.dispose();
    super.dispose();
  }



  _submit() async{
    if(_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    // 비밀번호와 비밀번호 확인이 일치하는지 확인
    if (_passController.text != _passConfirmController.text) {
      Get.snackbar('오류', '비밀번호와 비밀번호 확인이 일치하지 않습니다', snackPosition: SnackPosition.TOP);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    bool result = await authController.register(
      _idController.text,
      _passController.text,
      _nameController.text,
        null,
    );
    if(result) {
      Get.offAll(() => const HomeScreen());
    } else {
      // 에러 메시지는 auth_controller.dart에서 표시하므로 여기서는 추가 표시 생략
      print('Register failed, check auth_controller logs for details');
      // 추가 디버깅 정보 출력
      print('Input: uid=${_idController.text}, name=${_nameController.text}');
    }

    setState(() => _isLoading = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입'),),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            // 프로필 이미지
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.camera_alt , color: Colors.white, size: 30,
              ),
            ),
            const SizedBox(height: 16),
            // 아이디
            LabelTextfield(
              label: '아이디',
              hintText: '아이디를 입력해주세요',
              controller: _idController,
            ),
            const SizedBox(height: 14),
            // 비밀번호
            LabelTextfield(
              label: '비밀번호',
              hintText: '비밀번호를 입력해주세요',
              controller: _passController,
              isObscure: true,
            ),
            const SizedBox(height: 14),
            // 비밀번호 확인
            LabelTextfield(
              label: '비밀번호 확인',
              hintText: '비밀번호를 한번 더 입력해주세요',
              controller: _passConfirmController,
              isObscure: true,
            ),
            const SizedBox(height: 14),
            // 닉네임
            LabelTextfield(
              label: '닉네임',
              hintText: '닉네임을 입력해주세요',
              controller: _nameController,
              keyboardType: TextInputType.text, // 한글 입력 지원
              errorText: _nameError, // 실시간 에러 표시
            ),
            const SizedBox(height: 30,),
            // 버튼
            ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontWeight: FontWeight.bold , fontSize: 20),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity , 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white,)
                    : const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/screen/home_screen.dart';
import 'package:lifefit/widgets/forms/label_textfield.dart';
import 'package:lifefit/controller/auth_controller.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final authController = Get.put(AuthController());
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  _submit() async { // 로그인 기능
    bool result = await authController.login(
      _idController.text,
      _passwordController.text,
    );
    if(result){
      Get.offAll(() => const HomeScreen()); // 스택 다 제거후 화면 전환
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  const Text('로그인',),
      ),
      body: Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        children: [
          LabelTextfield(
              label: '아이디',
              hintText: '아이디를 입력하세요',
              controller: _idController,
          ),
          const SizedBox(height: 14,),
          LabelTextfield(
              label: '비밀번호',
              hintText: '비밀번호를 입력하세요',
              controller: _passwordController,
              isObscure: true,
          ),
          const SizedBox(height: 16,),
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
              child: const Text('로그인'),
          ),
        ],
      ),
      ),
    );
  }
}

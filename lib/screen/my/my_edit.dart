import 'package:flutter/material.dart';
import 'package:lifefit/widgets/forms/label_textfield.dart';
import 'package:lifefit/const/colors.dart';

// 사용자 프로필 정보를 수정 ( 이름 , 사용자 소개(커뮤니티에 쓰일부분)

class MyEdit extends StatefulWidget {
  const MyEdit({super.key});

  @override
  State<MyEdit> createState() => _MyEditState();
}

class _MyEditState extends State<MyEdit> {

  final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _contentController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            child: Icon(Icons.camera_alt , color: Colors.white , size: 30,),
          ),
          const SizedBox(height: 16,),
          LabelTextfield(
              label: '이름',
              hintText: '이름을 입력해주세요.',
              controller: _nameController,
          ),
          ElevatedButton(
              onPressed: (){},
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

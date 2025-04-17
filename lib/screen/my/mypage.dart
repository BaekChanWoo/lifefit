import 'package:flutter/material.dart';
import 'package:lifefit/model/user_model.dart';
import 'package:lifefit/screen/home_screen.dart';
import 'package:lifefit/widgets/listitems/user_mypage.dart';
import 'package:get/get.dart';


class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPage();
}

class _MyPage extends State<MyPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필
              UserMypage(UserModel(id: 1 , name: "백찬우")),
              // 기타 메뉴
              Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('나의 정보',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
              ),
              const ListTile(
                title: Text('프로필 수정'),
                leading: Icon(Icons.edit_note),
              ),
              const ListTile(
                title: Text('로그아웃'),
                leading: Icon(Icons.logout_outlined),
              ),
              const Divider(),
              ListTile(
                title: Text('홈'),
                leading: IconButton(
                    onPressed: (){
                      Get.offAll(() => const HomeScreen());
                    },
                    icon: Icon(Icons.home)),
              ),
            ],
          )
      ),
    );
  }
}

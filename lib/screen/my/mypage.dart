import 'package:flutter/material.dart';
import 'package:lifefit/model/user_model.dart';
import 'package:lifefit/screen/home_screen.dart';
import 'package:lifefit/widgets/listitems/user_mypage.dart';
import 'package:get/get.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/controller/auth_controller.dart';
import 'package:lifefit/screen/my/my_edit.dart';
import 'package:lifefit/controller/home_controller.dart';



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
              UserMypage(UserModel(id: 1 , name: Get.find<HomeScreenController>().userName.value)),
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
              ListTile(
                title: Text('프로필 수정'),
                leading: Icon(Icons.edit_note),
                onTap: (){
                  Get.to(() => const MyEdit(),
                    arguments: {
                    'name': Get.find<HomeScreenController>().userName.value,
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: const Text("로그아웃"),
                onTap: () {
                  Get.defaultDialog(
                    title: '로그아웃',
                    titleStyle:  const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold
                    ),
                    content: Text('정말 로그아웃하시겠습니까?',
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.white,
                    radius: 10.0,
                    confirm: ElevatedButton(
                      onPressed: () async {
                        final AuthController authController = Get.find<AuthController>();
                        await authController.logout();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                      ),
                      child: const Text(
                        '로그아웃',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    cancel: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
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

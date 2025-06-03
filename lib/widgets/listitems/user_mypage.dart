import 'package:flutter/material.dart';
import 'package:lifefit/model/user_model.dart';
import 'package:lifefit/screen/my/profile_detail.dart';
import 'package:get/get.dart';


class UserMypage extends StatelessWidget {
  final UserModel user;
  const UserMypage(this.user , {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Get.to(() => const ProfileDetail());
      },
      child: Padding(
          padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/img/mypageimg.jpg'),
                ),
                const SizedBox(width: 12,),
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: const Text(
                '프로필 보기',
                style: TextStyle(fontSize: 12 , fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}

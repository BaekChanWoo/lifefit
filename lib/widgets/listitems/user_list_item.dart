import 'package:flutter/material.dart';
import 'package:lifefit/model/user_model.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  const UserListItem(this.user , {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.transparent, // 배경 투명
            backgroundImage: AssetImage('assets/img/mypageimg.jpg'),
          ),
          const SizedBox(width: 10,),
          Text(user.name),
        ],
      ),
    );
  }
}

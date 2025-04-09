import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';

// 카테고리 버튼
class CategoryButton extends StatelessWidget {
  final VoidCallback? onTap;
  //final IconData icon;
  final String? title;

  const CategoryButton({
    super.key ,
    //required this.icon,
    this.onTap,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: PRIMARY_COLOR,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              title! ,
              style: TextStyle(fontSize: 14 , color: Colors.black
              ),
            ),
          ],
        ),
      ),
    );
  }
}

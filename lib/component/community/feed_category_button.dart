import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';

// 카테고리 버튼
class CategoryButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String? title;

  const CategoryButton({
    super.key ,
    required this.icon,
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Icon(
               icon , size: 16,),
              ), // title 의 값이 있는지를 판단
              if (title != null) const SizedBox(width:8),
              if (title != null)
              Text(
                title! ,
                style: TextStyle(fontSize: 14 , color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

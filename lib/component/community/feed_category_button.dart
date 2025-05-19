import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';
import 'package:get/get.dart';

// 카테고리 버튼
class CategoryButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final RxString isSelected; // 선택된 카테고리 추적


  const CategoryButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.title,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected.value == title || (title == '전체' && isSelected.value.isEmpty)
              ? PRIMARY_COLOR.withOpacity(0.8)
              : PRIMARY_COLOR.withOpacity(0.3),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Icon(
                icon , size: 16,
                color: isSelected.value == title || (title == '전체' && isSelected.value.isEmpty)
                    ? Colors.black
                    : Colors.grey,
              ),
            ), // title 의 값이 있는지를 판단
            const SizedBox(width: 8,),
            Text(
              title ,
              style: TextStyle(fontSize: 14 ,
                color: isSelected.value == title || (title == '전체' && isSelected.value.isEmpty)
                    ? Colors.black
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
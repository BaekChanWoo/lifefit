import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';


class CategorySelector extends StatelessWidget {
  final List<String> categories;

  // 현재 선택된 카테고리
  final String selectedCategory;
  // 카테고리 선택했을 때 콜백
  final Function(String) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // 좌우 스크롤
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory; // 현재 선택된 버튼인지 확인
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: TextButton(
              onPressed: () => onCategorySelected(category),
              style: TextButton.styleFrom(
                backgroundColor: isSelected ? PRIMARY_COLOR : Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // 둥글게 만들기
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

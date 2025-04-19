import 'package:flutter/material.dart';

class ChangeCategory extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String) onCategoryTap;
  final TextStyle? textStyle; // 기존 텍스트 스타일 파라미터 활용

  const ChangeCategory({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.selectedCategory,
    this.textStyle, // 텍스트 스타일 파라미터 유지
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () => onCategoryTap(category),
              child: Chip(
                avatar: Icon(
                  _getIconForCategory(category), // 카테고리에 맞는 아이콘 표시
                  color: Colors.black87,
                ),
                label: Text(
                  category,
                  style: textStyle,
                ),
                backgroundColor: isSelected ? Color(0xFF99FF99) : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

IconData _getIconForCategory(String category) {
  switch (category) {
    case '요가':
      return Icons.self_improvement;
    case '클라이밍':
      return Icons.terrain;
    case '사이클':
      return Icons.directions_bike;
    case '농구':
      return Icons.sports_basketball;
    case '러닝':
      return Icons.directions_run;
    case '헬스':
      return Icons.fitness_center;
    case '필라테스':
      return Icons.accessibility_new;
    default:
      return Icons.category;
  }
}

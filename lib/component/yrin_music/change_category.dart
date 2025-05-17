import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';

class ChangeCategory extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String) onCategoryTap;
  final TextStyle? textStyle;

  const ChangeCategory({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.selectedCategory,
    this.textStyle, //
  });

  @override  // 카테고리
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
                  _getIconForCategory(category),
                  color: Colors.black87,
                ),
                label: Text(
                  category,
                  style: textStyle,
                ),
                backgroundColor: isSelected ? PRIMARY_COLOR.withOpacity(0.8)
                    : PRIMARY_COLOR.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11.0),
                  // side: BorderSide.none,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


//카테고리 아이콘.
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

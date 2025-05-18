import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  IconData getCategoryIcon(String category) {
    switch (category) {
      case '전체':
        return Icons.all_inclusive;
      case '러닝':
        return Icons.directions_run;
      case '헬스':
        return Icons.fitness_center;
      case '요가':
        return Icons.self_improvement;
      case '필라테스':
        return Icons.accessibility_new;
      case '사이클':
        return Icons.directions_bike;
      case '클라이밍':
        return Icons.terrain;
      case '농구':
        return Icons.sports_basketball;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: TextButton(
              onPressed: () => onCategorySelected(category),
              style: TextButton.styleFrom(
                backgroundColor: isSelected
                    ? PRIMARY_COLOR.withOpacity(0.8)
                    : PRIMARY_COLOR.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Row(
                children: [
                  Icon(
                    getCategoryIcon(category),
                    size: 16,
                    color: isSelected ? Colors.black : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

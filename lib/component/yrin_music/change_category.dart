import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_music/category_images.dart';

class ChangeCategory extends StatefulWidget {

  final List<String> categories;
  final Function(String) onCategoryTap;
  final String? selectedCategory;


    const ChangeCategory({
    super.key,
    required this.categories,
    required this.onCategoryTap,
      this.selectedCategory,
  });

  @override
  State <ChangeCategory> createState() => _ChangeCategoryState();
}

class _ChangeCategoryState extends State<ChangeCategory> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [SingleChildScrollView(
        scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.categories.map((category) {
          final isSelected = category == widget.selectedCategory;
          return GestureDetector(
            onTap: () => widget.onCategoryTap(category),
            child: Container( //제스처 ontap
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF99FF99) : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(category,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: ' '//폰트 수정
                ),
              ),
            ),
          );
        }).toList(), // toList() 추가
      ),
    ),
          Flexible(
            child: CategoryImages(selectedCategory: widget.selectedCategory),
          ),
        ],
    );
  }
}



/* //url 이미지 서버 저장 후 사용 가능
    Expanded(
      child: widget.selectedCategory == null
          ? Image.asset(
        'assets/img/musicno.png', // 초기 이미지
        fit: BoxFit.cover,
      )
          : CategoryImages(category: widget.selectedCategory!),
    );
    */

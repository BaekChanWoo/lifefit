import 'package:flutter/material.dart';

class CategoryImages extends StatelessWidget {
  final String? selectedCategory;

  const CategoryImages({super.key, this.selectedCategory});

  List<String> getImagePaths(String? category) {
    if (category == null) {
      return []; // 초기 이미지 표시 시 빈 리스트 반환
    }


//이미지 서버 업로드 시 삭제 코드
    switch (category) {
      case '요가':
        return [ // 요가 케이스에 return 문 추가
          'assets/img/balance.png',
          'assets/img/flexible.png',
          'assets/img/meditation.png',
          'assets/img/respiration.png',
        ];
      default:
        return []; // 해당하는 카테고리가 없을 경우 빈 리스트 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePaths = getImagePaths(selectedCategory);

      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        // 스크롤 비활성화
        shrinkWrap: true,
        // GridView 크기
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 30, // 수평 간격
          mainAxisSpacing: 30,
          childAspectRatio: 1,// 수직 간격
        ),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(
                imagePaths[index],
                fit: BoxFit.cover,
          ),
          );
        },
      );

  }
}
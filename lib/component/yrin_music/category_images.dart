import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_music/music_page.dart';
import 'package:get/get.dart';

class CategoryImages extends StatelessWidget {
  final String? selectedCategory;

  const CategoryImages({super.key, this.selectedCategory});

  List<String> getImagePaths(String? category) {
    if (category == null) {
      return []; // 초기 이미지 표시 시 빈 리스트 반환
    }


    // 카테고리 이미지 경로
    switch (category) {
      case '요가':
        return [
          'assets/img/balance.png',
          'assets/img/flexible.png',
          'assets/img/meditation.png',
          'assets/img/respiration.png',
        ];
      case '클라이밍':
        return [
          'assets/img/climb.png',
          'assets/img/climbing_break.png',
          'assets/img/climbing_stretching.png',
          'assets/img/climbing_together.png',

        ];
      case '사이클':
        return [
          'assets/img/cysling.png',
          'assets/img/cycling_wind.png',
          'assets/img/cycling_rest.png',
          'assets/img/cycling_race.png',
          // 사이클
        ];
      case '농구':
        return [
          'assets/img/basketball cheerleading.png',
          'assets/img/basketball_dunk.png',
          'assets/img/basketball_pass.png',
          'assets/img/basketball_victory.png',
          // 농구
        ];
      case '러닝':
        return [
          'assets/img/run.png',
          'assets/img/run_rest.png',
          'assets/img/run_stretching.png',
          'assets/img/run_together.png',
          // 러닝
        ];
      case '헬스':
        return [
          'assets/img/health_lower.png',
          'assets/img/health_pt.png',
          'assets/img/health_run.png',
          'assets/img/health_up.png',
          // 헬스
        ];
      case '필라테스':
        return [
          'assets/img/pilates.png',
          'assets/img/pilates_alignment.png',
          'assets/img/pilates_ball.png',
          'assets/img/pilates_focus.png',
          //필라테스
        ];

      default:
        return []; // 해당하는 카테고리가 없을 경우 빈 리스트 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePaths = getImagePaths(selectedCategory);
    final  displayedImagePaths = imagePaths.take(4).toList();

    return GetMaterialApp( // GetMaterialApp으로 감싸기
        debugShowCheckedModeBanner: false,
        home: Column(
      children: [
        Expanded(
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 25,
            mainAxisSpacing: 20,
            children:  displayedImagePaths.map((path) {
              return GestureDetector(
                  onTap: () {
                    Get.to(() => MusicPage(categoryImages: path));
                  },
                  child:  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SizedBox(
                    width: 18,
                    height: 15,
                    child: Image.asset(
                    path,
                    fit: BoxFit.cover,
                ),
              ),
                   )
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 50), //
      ],
        )
    );

  }
}
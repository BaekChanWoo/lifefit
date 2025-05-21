import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_music/music_page.dart';

class CategoryImages extends StatelessWidget {
  final String? selectedCategory;

  const CategoryImages({super.key, this.selectedCategory});


  List<Map<String, String>> getImageData(String? category) {
    if (category == null) {
      return [];
    }

    switch (category) {
      case '요가':
        return [
          {'path': 'assets/img/balance.png', 'keyword': '요가 균형 음악 모음 playlsit'},
          {'path': 'assets/img/flexible.png', 'keyword': '요가 유연성 음악 모음 playlist'},
          {'path': 'assets/img/meditation.png', 'keyword': '요가 명상 음악 모음 playlsit'},
          {'path': 'assets/img/respiration.png', 'keyword': '요가 호흡 음악 모음 playlsit'},
        ];
      case '클라이밍':
        return [
          {'path': 'assets/img/climb.png', 'keyword': '클라이밍 음악 playlist 도전'},
          {'path': 'assets/img/climbing_break.png', 'keyword': '클라이밍 휴식 음악 모음 playlsit'},
          {'path': 'assets/img/climbing_stretching.png', 'keyword': '클라이밍 climbing 음악 playlsit'},
          {'path': 'assets/img/climbing_together.png', 'keyword': '클라이밍 할 때 듣는 음악 playlsit'},
        ];
      case '사이클':
        return [
          {'path': 'assets/img/cysling.png', 'keyword': '자전거 라이딩 음악 모음 playlsit'},
          {'path': 'assets/img/cycling_wind.png', 'keyword': '사이클 청량 바람 음악 playlsit'},
          {'path': 'assets/img/cycling_rest.png', 'keyword': '사이클 휴식 음악 playlsit'},
          {'path': 'assets/img/cycling_race.png', 'keyword': '사이클 질주 음악 playlsit'},
        ];
      case '농구':
        return [
          {'path': 'assets/img/basketball cheerleading.png', 'keyword': '농구 응원 음악 playlsit'},
          {'path': 'assets/img/basketball_dunk.png', 'keyword': '농구 에너지 음악 playlsit'},
          {'path': 'assets/img/basketball_pass.png', 'keyword': '농구 힙합 음악 playlist'},
          {'path': 'assets/img/basketball_victory.png', 'keyword': '농구 승리 음악 playlsit'},
        ];
      case '러닝':
        return [
          {'path': 'assets/img/run.png', 'keyword': '러닝 외힙 음악 playlsit'},
          {'path': 'assets/img/run_rest.png', 'keyword': '러닝 산책 음악 playlsit'},
          {'path': 'assets/img/run_stretching.png', 'keyword': '스트레칭 음악 playlsit'},
          {'path': 'assets/img/run_together.png', 'keyword': '러닝 빡센 음악 playlsit'},
        ];
      case '헬스':
        return [
          {'path': 'assets/img/health_lower.png', 'keyword': '하체 운동 음악 playlsit'},
          {'path': 'assets/img/health_pt.png', 'keyword': '헬스 쇠질 음악 playlsit'},
          {'path': 'assets/img/health_run.png', 'keyword': '헬스 유산소 음악 playlsit'},
          {'path': 'assets/img/health_up.png', 'keyword': '상체 운동 음악 playlsit'},
        ];
      case '필라테스':
        return [
          {'path': 'assets/img/pilates.png', 'keyword': '필라테스 집중 음악 playlsit'},
          {'path': 'assets/img/pilates_alignment.png', 'keyword': '필라테스 조용한 음악 playlsit'},
          {'path': 'assets/img/pilates_ball.png', 'keyword': '필라테스 부드러운 피아노 음악 playlsit'},
          {'path': 'assets/img/pilates_focus.png', 'keyword': '필라테스 스트레칭 음악 playlsit'},
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageData = getImageData(selectedCategory);
    final displayedImageData = imageData.take(4).toList();

    return Column(
      children: [
        Expanded(
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 25,
            mainAxisSpacing: 20,
            children: displayedImageData.map((data) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          MusicPage(categoryImages: data['path']!,
                              searchKeyword: data['keyword']!),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: SizedBox(
                    width: 18,
                    height: 15,
                    child: Image.asset(
                      data['path']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
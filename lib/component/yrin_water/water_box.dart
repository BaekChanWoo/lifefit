import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_water/water_service.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class WaterBox extends StatefulWidget {
  final VoidCallback onContainerTapped;

  const WaterBox({super.key, required this.onContainerTapped});

  @override
  State<WaterBox> createState() => WaterBoxState();
}

class WaterBoxState extends State<WaterBox> {
  int todayIntake = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTodayIntake();
  }

  Future<void> loadTodayIntake() async {
    setState(() => isLoading = true);
    final intake = await WaterService().getTotalAmountForToday();
    setState(() {
      todayIntake = intake;
      isLoading = false;
    });
  }

  void refreshData() {
    loadTodayIntake();
  }

  @override
  Widget build(BuildContext context) {
    const goalAmount = 2000;
    final firstThird = 650;
    final secondThird = 1300;

    // 섭취량 구간별 메시지 설정
    String getStatusMessage() {
      if (todayIntake < firstThird) {
        return "우리 몸, 물이 필요해요!";
      } else if (todayIntake < secondThird) {
        return "조금만 더 마셔요!";
      } else if (todayIntake < goalAmount) {
        return "조금만 더 마셔요!";
      } else {
        return "오늘 목표 달성!";
      }
    }

    return GestureDetector(
      onTap: () {
        widget.onContainerTapped();
        Navigator.of(context).pushNamed('water').then((_) {
          refreshData(); // 물 페이지에서 돌아왔을 때 새로고침
        });
      },
      child: Container(
        height: 180, //컨테이너 높이
        width: MediaQuery.of(context).size.width - 240,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "물",
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.water_drop,
                    color: Colors.blue,
                    size: 20.0,
                  ),
                ],
              ),
              const SizedBox(height: 15), //물과SleekCircularSlider 사이즈박스 간격
              isLoading
                  ? const SizedBox(
                height: 100,
                width: 100,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
                  : Column(
                children: [
                  SizedBox(
                    height: 90,
                    width: 100,
                    child: SleekCircularSlider(
                      min: 0,
                      max: goalAmount.toDouble(),
                      initialValue: todayIntake.toDouble(),
                      appearance: CircularSliderAppearance(
                        size: 100,
                        customWidths: CustomSliderWidths(
                          trackWidth: 10,
                          progressBarWidth: 10,
                        ),
                        customColors: CustomSliderColors(
                          trackColor: Colors.grey.shade300,
                          progressBarColor: const Color(0xFFB3D9FF),
                          dotColor: Colors.transparent,
                        ),
                        infoProperties: InfoProperties(
                          mainLabelStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          modifier: (value) =>
                          "${todayIntake.clamp(0, goalAmount)}/${goalAmount}mL",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5), //그래프랑 텍스트 사이즈 박스
                  Text(
                    getStatusMessage(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
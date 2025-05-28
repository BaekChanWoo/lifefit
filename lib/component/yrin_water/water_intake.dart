import 'package:flutter/material.dart';

class WaterIntake extends StatelessWidget {
  final Function(int) onAmountChanged; // 물 양이 변경되었을 때 호출될 콜백
  final int currentTotalAmount; // WaterProvider로부터 전달받는 현재 총 물 섭취량
  final int dailyWaterGoal; // WaterProvider로부터 전달받는 일일 목표량 (2000ml)

  const WaterIntake({
    super.key,
    required this.onAmountChanged,
    this.currentTotalAmount = 0, // 기본값 설정
    required this.dailyWaterGoal, // WaterHome에서 이 값을 필수로 전달해야 함
  });

  @override
  Widget build(BuildContext context) {
    // Scaffold 제거: WaterIntake는 WaterHome의 body 안에 들어가는 위젯이므로 Scaffold를 가지지 않습니다.
    return Column( // AppBar가 제거되었으므로, 전체를 Column으로 감싸서 배치합니다.
      mainAxisSize: MainAxisSize.min, // 필요한 만큼만 공간 차지
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 물 섭취량 타이틀 (AppBar 대체)
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            '물 섭취량',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontFamily: 'NanumSquareRound',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Container(
          width: 500, // 최대 너비
          height: 240,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: const EdgeInsets.all(20), // 상위 Column의 패딩과 겹치지 않게 주의

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // 물 이미지
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    'assets/img/cup.png',
                    width: 95,
                    height: 95,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 85, top: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 플러스 버튼 이벤트
                    GestureDetector(
                      onTap: () {
                        // WaterProvider에서 2000ml 제한을 관리하므로, 여기서는 단순히 전달
                        onAmountChanged(250); // 250ml 증가
                      },
                      child: Image.asset(
                        'assets/img/plus.png',
                        width: 25,
                        height: 25,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      '250 mL',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'NanumSquareRound',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 15),
                    // 마이너스 버튼 이벤트: currentTotalAmount가 dailyWaterGoal에 도달하면 비활성화
                    GestureDetector(
                      onTap: currentTotalAmount >= dailyWaterGoal ? null : () {
                        // 물의 양이 0보다 작아지지 않도록 방지
                        if (currentTotalAmount - 50 >= 0) {
                          onAmountChanged(-50); // 50ml 감소
                        } else {
                          onAmountChanged(-currentTotalAmount); // 0으로 만들기
                        }
                      },
                      child: Image.asset(
                        'assets/img/substract.png',
                        width: 25,
                        height: 25,
                        fit: BoxFit.contain,
                        // 2000ml 도달 시 이미지 투명하게 하여 비활성화 시각화 (선택 사항)
                        color: currentTotalAmount >= dailyWaterGoal ? Colors.grey.withOpacity(0.5) : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              Padding(
                padding: const EdgeInsets.only(left: 34),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '총 섭취량',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'NanumSquareRound',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          // 결과 상자
                          width: 100,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF5F3F3),
                          ),
                        ),
                        Padding(
                          // 물 누적 값 (currentTotalAmount 사용)
                          padding: const EdgeInsets.only(right: 20, top: 0),
                          child: Text(
                            '$currentTotalAmount', // <-- 현재 총 섭취량 사용
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'NanumSquareRound',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Padding(
                          padding: EdgeInsets.only(left: 58, top: 0),
                          child: Text(
                            'mL',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'NanumSquareRound',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 10),
                    // dailyWaterGoal 사용
                    Padding(
                      padding: const EdgeInsets.only(left: 0, top: 10),
                      child: Text(
                        '/ ${dailyWaterGoal.toStringAsFixed(0)}mL', // 목표량 표시
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontFamily: 'NanumSquareRound',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
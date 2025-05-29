import 'package:flutter/material.dart';
//
class WaterIntake extends StatelessWidget {
  final Function(int) onAmountChanged;
  final int currentTotalAmount;
  final int dailyWaterGoal;

  const WaterIntake({
    super.key,
    required this.onAmountChanged,
    this.currentTotalAmount = 0,
    required this.dailyWaterGoal,
  });

  @override
  Widget build(BuildContext context) {

    final bool canDecrease = currentTotalAmount > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
          width: 500,
          height: 240,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: const EdgeInsets.all(20),
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
                    // 플러스 버튼
                    GestureDetector(
                      onTap: () {
                        // 부모가 2000ml 제한을 처리하므로 여기서는 무조건 호출
                        onAmountChanged(250);
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
                    // 마이너스 버튼
                    GestureDetector(
                      onTap: canDecrease
                          ? () {
                        // 50ml 단위로 감소, 0 이하로 내려가지 않도록 조절
                        if (currentTotalAmount - 50 >= 0) {
                          onAmountChanged(-50);
                        } else {
                          onAmountChanged(-currentTotalAmount);
                        }
                      }
                          : null,
                      child: Image.asset(
                        'assets/img/substract.png',
                        width: 25,
                        height: 25,
                        fit: BoxFit.contain,
                        color: canDecrease ? null : Colors.grey.withOpacity(0.5),
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
                          width: 100,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF5F3F3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text(
                            '$currentTotalAmount',
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
                          padding: EdgeInsets.only(left: 58),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 0, top: 10),
                      child: Text(
                        '/ ${dailyWaterGoal.toStringAsFixed(0)}mL',
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
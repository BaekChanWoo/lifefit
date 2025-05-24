import 'package:flutter/material.dart';

class WaterIntake extends StatefulWidget {
  final Function(int) onAmountChanged;
  final int initialWaterAmount;
  final int currentTotalAmount;
  const WaterIntake({
    super.key,
    required this.onAmountChanged,
    this.initialWaterAmount = 0,
    this.currentTotalAmount = 0,
  });

  @override
  State<WaterIntake> createState() => _WaterIntakeState();
}

class _WaterIntakeState extends State<WaterIntake> {
  int _displayWaterAmount = 0; // 컵에 표시될 물 양

  @override
  void initState() {
    super.initState();
    _displayWaterAmount = widget.initialWaterAmount;
  }

  void _addOrSubtractWater(int amount) {
    setState(() {
      _displayWaterAmount += amount;
      if (_displayWaterAmount < 0) {
        _displayWaterAmount = 0; // 물 양 음수 방지
      }
    });

    widget.onAmountChanged(amount);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경색 회색

      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          padding: EdgeInsets.all(10),
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
        centerTitle: true,
      ),

      // 물 바디.
      body: Stack(
        children: [
          Positioned(
            top: -20,
            left: 10,
            right: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                        padding: const EdgeInsets.only(left: 100, top: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 플러스 버튼 이벤트
                            GestureDetector(
                              onTap: () {
                                _addOrSubtractWater(250); // 250ml 증가
                              },
                              child: Image.asset(
                                'assets/img/plus.png',
                                width: 25,
                                height: 25,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              '250 mL',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'NanumSquareRound',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 15),
                            // 마이너스 버튼 이벤트
                            GestureDetector(
                              onTap: () {
                                _addOrSubtractWater(-50); // 50ml 감소
                              },
                              child: Image.asset(
                                'assets/img/substract.png',
                                width: 25,
                                height: 25,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 13),
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
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
                                  // 물 누적 값
                                  padding: const EdgeInsets.only(right: 20, top: 0),
                                  child: Text(
                                    '$_displayWaterAmount',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'NanumSquareRound',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Padding(
                                  padding: const EdgeInsets.only(left: 58, top: 0),
                                  child: const Text(
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
                              child: const Text(
                                '/ 2,000mL',
                                style: TextStyle(
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
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_water/water_reset.dart';

class WaterIntake extends StatefulWidget {
  final int initialWaterAmount;
  final Function(int) onAmountChanged;

  const WaterIntake({
    super.key,
    required this.initialWaterAmount,
    required this.onAmountChanged,
  });


  @override
  State<WaterIntake> createState() => _WaterIntakeState();
}

class _WaterIntakeState extends State<WaterIntake> {
  int _currentWaterAmount = 0;

  @override
  void initState() {
    super.initState();
    _currentWaterAmount = widget.initialWaterAmount; // 초기값 설정
    // 앱 시작 시 자정 여부 확인 및 초기화, 저장된 값 로딩
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WaterResetService.scheduleDailyReset(setState, _updateWaterAmount);
    });
  }

  // 로컬 waterAmount 상태를 업데이트하고 저장하는 함수
  void _updateWaterAmount(int newAmount) {
    setState(() {
      _currentWaterAmount = newAmount; // 현재 물의 양 업데이트
      widget.onAmountChanged(newAmount); // 부모 위젯의 상태 업데이트
    });
    WaterResetService.saveWaterAmount(newAmount); // 영구 저장
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD), // 전체 배경색 회색

      appBar: AppBar(
        backgroundColor: const Color(0xFFDDDDDD),
        title: Container(
          padding: EdgeInsets.all(10),
          child: Text(
            '물 섭취량',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontFamily: 'Padauk',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        centerTitle: true,
      ),

      // 물 바디
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 400,
                  height: 250,

                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), //수정필요
                  margin: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white
                  ),

                  child: Column(
                    children: [ //물 이미지
                      Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Image.asset(
                            'assets/img/cup.png',
                            width:95,
                            height: 95,
                            fit: BoxFit.contain,),
                        ),
                      ),

                      SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.only(left: 100, top: 5,),
                        child:  Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //플러스 버튼 이벤트
                            GestureDetector(
                              onTap: () {
                                WaterResetService.incrementWaterAmount(
                                    _currentWaterAmount, 250, _updateWaterAmount);

                              },
                              child: Image.asset('assets/img/plus_button.png',
                                width: 25,
                                height: 25,
                                fit: BoxFit.contain,
                              ),
                            ),


                            SizedBox(width: 15),

                            Text(
                                '250 mL',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Padauk',
                                  fontWeight: FontWeight.w700,)
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: 13,),

                      Padding(
                        padding: const  EdgeInsets.only(left: 50),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('총 섭취량',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Padauk',
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            SizedBox(width: 5,),

                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(  //결과 표시 상자
                                  width: 100,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFFF5F3F3),
                                  ),
                                ),
                                Padding(  // 물 누적 값
                                  padding: const EdgeInsets.only(right: 20, top: 0),
                                  child: Text(
                                    '$_currentWaterAmount',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Padauk',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 14,),

                                Padding(
                                  padding: const EdgeInsets.only(left: 58, top: 0),
                                  child: Text('mL',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Padauk',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(width: 10,),

                            Padding(
                              padding: const EdgeInsets.only(left:0, top: 10),
                              child: Text('/ 2,000mL',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: 'Padauk',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )
              )
            ],
          )
        ],
      ),
    );
  }
}
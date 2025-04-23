import 'package:flutter/material.dart';

class WaterIntake extends StatefulWidget {
  final int waterAmount;
  final Function(int) onAmountChanged;

  const WaterIntake({
    super.key,
    required this.waterAmount,
    required this.onAmountChanged, // 이름 변경
  });


  @override
  State<WaterIntake> createState() => _WaterIntakeState();
}

class _WaterIntakeState extends State<WaterIntake> {

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
              fontSize: 24,
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
                                setState(() {
                                  if (widget.waterAmount + 250<= 2000){
                                    widget.onAmountChanged(widget.waterAmount + 250) ;
                                  }
                                });
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
                                    '${widget.waterAmount}',
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
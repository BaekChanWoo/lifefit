import 'package:flutter/material.dart';

void main() { // WaterHome 호출
  runApp(const WaterHome());
}

class WaterHome extends StatefulWidget {
  const WaterHome({super.key});

  @override
  State<WaterHome> createState() => _WaterHomeState();
}

class _WaterHomeState extends State<WaterHome> {
  int waterAmount = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFB9B9B9), // 전체 배경색 회색

        appBar: AppBar(backgroundColor: const Color(0xFFB9B9B9),
            title: Container(
              padding: EdgeInsets.all( 10 ),

              child:
              Text('물 섭취량',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontFamily: 'Padauk',
                  fontWeight: FontWeight.w700,),
              ),
            )
        ),
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 400,
                    height: 280,

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
                              width:115,
                              height: 115,
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
                                    if (waterAmount + 250<= 2000){
                                      waterAmount += 250;
                                    }
                                  });
                                },
                                child: Image.asset('assets/img/plus_button.png',
                                  width: 27,
                                  height: 27,
                                  fit: BoxFit.contain,
                                ),
                              ),


                              SizedBox(width: 20),

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

                        SizedBox(height: 15,),

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
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20, top: 0),
                                    child: Text('$waterAmount',
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
      ),
    );
  }
}
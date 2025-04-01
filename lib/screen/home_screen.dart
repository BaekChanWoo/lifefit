import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifefit/widgets/bottom_bar.dart';
import 'package:lifefit/const/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark); // 상태바 검은색

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        title: Padding(
          padding: EdgeInsets.only(left: 9),
          child: Text("라이프핏",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        actions: [
          /*CircleAvatar(
                radius: 17,
                backgroundColor: PRIMARY_COLOR,
              ),*/
          Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(Icons.list,
                    size: 35,
                  ),
                  onPressed: (){
                    print("클릭됨");
                    Scaffold.of(context).openEndDrawer(); // 오른쪽 Drawer 열기
                  },
                );
              }
          ),
        ],
      ),
      // 상다 바
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: PRIMARY_COLOR,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text("내 정보",
                      //textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black , fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 10.0,),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: SERVE_COLOR,
                        radius: 30.0,
                      ),
                      const SizedBox(width: 20.0,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.0),
                              border: Border.all(
                                color: Colors.green,
                                width: 1.0,
                              ),
                            ),
                            child: Text("라이프핏 개인 프로필",
                              style: TextStyle(
                                fontSize: 15.0,
                                color: PRIMARY_TEXT_COLOR,
                              ),
                            ),
                          ),
                          Text("백찬우",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ) ,
            ),
            ListTile(
              leading: Text("라이프핏",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("홈"),
              onTap: (){},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("설정"),
              onTap: (){},
            ),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text("질문"),
              onTap: (){},
            ),
          ],
        ),
      ),
      // 오른쪽 상단 메뉴 아이콘
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              height: 305,
              decoration: BoxDecoration(
                  color: PRIMARY_COLOR
              ),
              child: Container(
                padding: EdgeInsets.only(top: 25 , left: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                        text: TextSpan(
                            text: "안녕하세요 ",
                            style: TextStyle(
                              letterSpacing: 1.0,
                              fontSize: 20,
                              fontWeight: FontWeight.w500 ,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                  text: "백찬우님",
                                  style: TextStyle(
                                    letterSpacing: 2.0,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  )
                              )
                            ]
                        )
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 안녕하세요 백찬우님
          Positioned(
              top: 80,
              child: Container(
                height: 120,
                width: MediaQuery.of(context).size.width-60,
                margin: EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("일일 챌린지",
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5.0,),
                      Text("10000 걸음 걷기",
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ),
          // 일일 챌린지
          Positioned(
            top: 210,
            child: Container(
              height: 175,
              width: MediaQuery.of(context).size.width-240,
              margin: EdgeInsets.symmetric(horizontal: 30),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text( "건강 정보/기사",
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.local_fire_department,
                          color: Colors.deepOrange,
                          size: 20.0,
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),
          // 건강 정보 기사
          Positioned(
            top: 210,
            right: 0,
            child: Container(
              height: 175,
              width: MediaQuery.of(context).size.width-240,
              margin: EdgeInsets.symmetric(horizontal: 30),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text( "미세먼지/날씨",
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.cloud,
                          color: Colors.purpleAccent,
                          size: 20.0,
                        ),
                      ],
                    )

                  ],
                ),
              ),
            ),
          ),
          // 미세먼지/
          Positioned(
            top: 395,
            right: 0,
            child: Container(
              height: 120,
              width: MediaQuery.of(context).size.width-240,
              margin: EdgeInsets.symmetric(horizontal: 30),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text( "수면시간",
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.dark_mode,
                          color: Colors.yellow,
                          size: 20.0,
                        )
                      ],
                    )

                  ],
                ),
              ),
            ),
          ),
          // 수면 시간
          Positioned(
            top: 395,
            child: Container(
              height: 120,
              width: MediaQuery.of(context).size.width-240,
              margin: EdgeInsets.symmetric(horizontal: 30),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text( "물",
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.water_drop,
                          color: Colors.blue,
                          size: 20.0,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 물
        ],
      ),

      // 하단 바
      bottomNavigationBar: MainBottomNavigationBar(),
    );
  }
}

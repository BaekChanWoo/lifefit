import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifefit/widgets/bottom_bar.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/screen/sleep.dart';
import 'package:lifefit/screen/calendar.dart';
import 'package:lifefit/screen/community.dart';
import 'package:lifefit/screen/meet_up.dart';
import 'package:lifefit/screen/healthtopic.dart';
import 'package:lifefit/screen/weather.dart';
import 'package:lifefit/screen/water.dart';
import 'package:lifefit/screen/pedometer.dart';
import 'package:get/get.dart';
import 'package:lifefit/screen/my/mypage.dart';
import 'package:lifefit/screen/music.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:lifefit/controller/auth_controller.dart';
import 'package:lifefit/controller/home_controller.dart';

import '../component/pedometer/daily_challenge.dart';
import '../component/pedometer/step_progress_bar.dart';
import '../component/sleep/sleep_card.dart';
import 'package:timeago/timeago.dart' as timeago;



// 다른 화면에서 홈페이지로 이동하려면 HomeScreen 클래스 호출
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;               // 현재 선택된 하단 내비게이션 탭의 인덱스
  bool _isContainerPage = false;        // 홈 화면 내 세부 페이지 진입 여부( 예: SleepScreen)
  late PageController _pageController;  // 탭 간 전환을 관리
  late List<Widget> _screens;           // 각 탭에 해당하는 화면 리스트
  final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
  // Navigator 키 추가
  // 홈 화면 내 중첩 Navigator를 제어하기 위한 키

  @override
  void initState(){
    super.initState();
    // Get.arguments에서 selectedTab 확인
    int initialTab = Get.arguments != null && Get.arguments['selectedTab'] != null
        ? Get.arguments['selectedTab']
        : 0;
    _selectedIndex = initialTab;

    _pageController = PageController(initialPage: _selectedIndex); // 홈 화면(중첩 내비게이션 포함)
    // 탭에 표시될 화면 초기화
    _screens = [
      HomeContentWithNavigation(
          navigatorKey: _homeNavigatorKey,
          onPopToHome: _handlePopToHome, // 콜백 추가
      ), // 키 전달
      const MeetUpScreen(),
      const Calendar(),
      const Community(),
      const Music(),
    ];
  }

  // 하단 내비게이션 바 탭 클릭시 호출되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isContainerPage = false;    // 탭(하단 바) 전환 시 컨테이너 페이지 상태 해제
      _pageController.animateToPage(
          index,
          duration: const Duration(microseconds: 300),
          curve: Curves.easeInOut, // 부드러운 전환 곡선
      );
      if (index == 0) { // 홈 택 클릭시
        // 중첩 Navigator의 스택에서 첫 번째 라우트까지 모든 페이지를 pop
        _homeNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    });
  }

  // 홈 화면 내 컨테이너 클릭시 호출되는 함수
  void _onContainerTapped(){
    setState(() {
      _isContainerPage = true; // 컨테이너 페이지로 전환시(진입) 상태 설정
    });
  }

  // 뒤로 가기로 홈 화면 복귀 시 호출될 콜백
  void _handlePopToHome() {
    setState(() {
      _isContainerPage = false;
    });
  }

  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 인증 상태 감지
    // authStateChanges().listen으로 로그아웃 감시 -> /intro로 리다이렉트
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        Get.offAllNamed('/intro');
      }
    });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark); // 상태바 검은색

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 0 && !_isContainerPage // 컨테이너 페이지에서는 AppBar 숨김
          ? AppBar( // 홈 화면일 때만 AppBar 표시
        backgroundColor: PRIMARY_COLOR,
        title: Padding(
          padding: EdgeInsets.only(left: 9 ),
          child: Image.asset('assets/img/lifefit.png',
          fit: BoxFit.contain,
          width: 40,
          height: 40,
          ),
        ),
        actions: [
          Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.list,
                    size: 40,
                  ),
                  onPressed: (){
                    Scaffold.of(context).openEndDrawer(); // 오른쪽 Drawer 열기
                  },
                );
              }
          ),
        ],
      ) : null ,                       // 다른 화면에서는 AppBar 없음
      // 상단 바
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                iconTheme: IconThemeData(color: Colors.black),
              ),
              child: Obx(
                () => UserAccountsDrawerHeader(
                    accountName: Text(
                      Get.find<HomeScreenController>().userName.value,
                      style: TextStyle(
                          color: Colors.black ,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                      ),
                    ),
                    accountEmail: null,
                  onDetailsPressed: () {},
                  arrowColor: Colors.black,
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage('assets/img/mypageimg.jpg'),
                  ),
                  otherAccountsPictures: [
                    Obx(() {
                          final last = Get.find<HomeScreenController>().lastLoginTime.value;
                          return Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               const Icon(Icons.access_time, color: Colors.black, size: 23),
                               Text(
                                 timeago.format(last),
                                 style: const TextStyle(fontSize: 10, color: Colors.black),
                               ),
                             ],
                           );
                         }),
                  ],
                  decoration: BoxDecoration(
                    color: PRIMARY_COLOR,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    )
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Text("라이프핏",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("홈"),
              onTap: (){
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("설정"),
              onTap: (){},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("프로필"),
              onTap: (){
                Get.to(() => MyPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text("로그아웃"),
              onTap: () {
                Get.defaultDialog(
                  title: '로그아웃',
                  titleStyle:  const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold
                  ),
                  content: Text('정말 로그아웃하시겠습니까?',
                  style: TextStyle(
                    color: Colors.grey[800],
                  ),
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: Colors.white,
                  radius: 10.0,
                  confirm: ElevatedButton(
                    onPressed: () async {
                      final AuthController authController = Get.find<AuthController>();
                      await authController.logout();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_COLOR,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                    ),
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  cancel: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_COLOR,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // 오른쪽 상단 메뉴 아이콘
      // 본문: 탭에 따라 표시되는 화면
      body:  PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // 스와이프 비활성화 ( 탭 클릭으로만 전환)
        children: _screens,
      ),

      // 하단 내비게이션 바
      bottomNavigationBar: MainBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        isContainerPage : _isContainerPage, // 컨테이너 페이지 상태 전달
      ),
    );
  }
}


// 중첩 Navigator의 pop 이벤트를 감지하는 Observer
class CustomNavigatorObserver extends NavigatorObserver {
  final VoidCallback onPopToHome; // 콜백 사용

  CustomNavigatorObserver(this.onPopToHome);

  @override
  void didPop(Route route, Route? previous) {
    // 세부 페이지에서 홈으로 돌아올 때 콜백 호출
    if (route.settings.name != 'home' && previous != null && previous.settings.name == 'home') {
      onPopToHome(); // 조건이 참일 때 호출
    }
  }
}

// 홈 화면 내 중첩 내비게이션을 관리
class HomeContentWithNavigation extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey; // Navigator 키 추가
  final VoidCallback onPopToHome;               // 뒤로 가기 시 호출될 콜백 추가

  const HomeContentWithNavigation({
    super.key,
    required this.navigatorKey,
    required this.onPopToHome,
  });

  @override
  Widget build(BuildContext context) { // as Element 는 Element로 캐스팅한것(트리 탐색 메서드)
    final homeState = (context as Element).findAncestorStateOfType<_HomeScreenState>();
    return  Navigator(
        key: navigatorKey,
        initialRoute: 'home',
        observers: [CustomNavigatorObserver(onPopToHome)], // 뒤로 가기 감지용 Observer 추가
        onGenerateRoute: (RouteSettings settings) {        // 라우트 이름에 따라 페이지를 동적으로 생성
        WidgetBuilder builder;
        switch (settings.name) {
            case 'home':
              builder = (BuildContext _) => HomeContent(
                onContainerTapped: () {
                  homeState!._onContainerTapped();
                },
              );
              break;
            case 'daily_challenge':
              builder = (BuildContext _) => const Pedometer();
              break;
            case 'health_info':
              builder = (BuildContext _) => const Healthtopic();
              break;
            case 'weather':
              builder = (BuildContext _) => const Weather();
              break;
            case 'water':
              builder = (BuildContext _) => const WaterHome();
              break;
            case 'sleep_time':
              builder = (BuildContext _) => const SleepScreen();
              break;
            default:
              throw Exception('유효하지 않은 페이지 : ${settings.name}');
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
    );
  }
}


// 컨테이너 5개는 다 세부페이지
class HomeContent extends StatefulWidget {

  final VoidCallback onContainerTapped;
  const HomeContent({super.key , required this.onContainerTapped});


  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final GlobalKey<SleepCardState> sleepCardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          child: Container(
            height: 345,
            decoration: BoxDecoration(
                color: PRIMARY_COLOR
            ),
            child: Container(
              padding: EdgeInsets.only(
                  top: 35 ,
                  left: 25
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                  () =>  RichText(
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
                                  text: "${Get.find<HomeScreenController>().userName.value}님",
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
                  ),
                ],
              ),
            ),
          ),
        ),
        // 안녕하세요 SKHU님
        Positioned(
            top: 100,
            child: GestureDetector(
              onTap: (){
                widget.onContainerTapped();
                Navigator.of(context).pushNamed('daily_challenge');
              },
              child: Container(
                height: 130,
                width: MediaQuery.of(context).size.width-60,
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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("일일 챌린지",
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      const Text("10000 걸음 목표!",
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const DailyChallenge(),
                    ],
                  ),
                ),

              ),
            )
        ),
        // 일일 챌린지
        Positioned(
          top: 240,
          child: GestureDetector(
            onTap: (){
              widget.onContainerTapped();
              Navigator.of(context).pushNamed('health_info');
            },
            child: Container(
              height: 175,
              width: MediaQuery.of(context).size.width-240,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
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
                         Icon(Icons.newspaper,
                          color: Colors.green,
                          size: 20.0,
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
        // 건강 정보 기사
        Positioned(
          top: 240,
          right: 0,
          child: GestureDetector(
            onTap: (){
              widget.onContainerTapped();
              Navigator.of(context).pushNamed('weather');
            },
            child: Container(
              height: 175,
              width: MediaQuery.of(context).size.width-240,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
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
        ),
        // 미세먼지/
        Positioned(
          top: 425,
          right: 0,
          child: SleepCard(
            key: sleepCardKey, // key 추가!
            onTap: () {
              widget.onContainerTapped();
              Navigator.of(context).pushNamed('sleep_time').then((_) {
                // 수면 기록하고 돌아왔을 때 다시 불러오기
                sleepCardKey.currentState?.refreshData();
              });
            },
          ),
        ),
        // 수면 시간
        Positioned(
          top: 425,
          child: GestureDetector(
            onTap: (){
              widget.onContainerTapped();
              Navigator.of(context).pushNamed('water');
            },
            child: Container(
              height: 145,
              width: MediaQuery.of(context).size.width-240,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 물
    ],
    );
  }
}

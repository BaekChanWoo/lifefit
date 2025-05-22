import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lifefit/screen/auth/register.dart';
import 'package:lifefit/controller/auth_controller.dart';
import 'package:lifefit/screen/home_screen.dart';
import 'package:get/get.dart';
import 'package:lifefit/firebase_options.dart';
import 'package:lifefit/screen/auth/intro.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'shared/global.dart';
import 'dart:developer';
import 'package:lifefit/controller/home_controller.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:timeago/timeago.dart' as timeago;




void main() async {

  WidgetsFlutterBinding.ensureInitialized(); // 비동기 초기화 준비

  MobileAds.instance.initialize();

  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // 주석 처리된 코드: 인증 상태 유지 설정 (로컬 저장소 사용)
    // await firebase_auth.FirebaseAuth.instance.setPersistence(firebase_auth.Persistence.LOCAL);
    log('Firebase initialized successfully');
  } catch (e) {
    log('Firebase initialization error: $e');
  }

  await initializeDateFormatting('ko_KR', null);
  // 한국어 메시지 등록
  timeago.setLocaleMessages('ko', timeago.KoMessages());
  // (선택) 한 번만 등록하면 매번 locale 파라미터를 생략
  timeago.setDefaultLocale('ko');

  // GetX 의존성 초기화
  Get.put(AuthController(), permanent: true); // 영속 인스턴스
  Get.lazyPut(() => AuthController(), fenix: true);
  Get.lazyPut(() => HomeScreenController(), fenix: true);


  // Firebase 인증 상태 확인
  firebase_auth.User? initialUser;
  // authStateChanges 스트림에서 첫 번째 사용자 상태를 가져옴( 로그인 여부 확인 )
  await for (var user in firebase_auth.FirebaseAuth.instance.authStateChanges().take(1)) {
    initialUser = user;
    break;
  }

  // 초기 토큰 캐싱: 로그인한 사용자가 있는 경우에만 실행
  if (initialUser != null) {
    try {
      // Firebase ID 토큰을 갱신하고 Global.accessToken에 저장
      await Global.updateAccessToken();
      log('Initial Firebase ID Token: ${Global.accessToken}');
    } catch (e) {
      log('Initial updateAccessToken error: $e');
      // 토큰 갱신 실패 시 로그아웃 처리
      await firebase_auth.FirebaseAuth.instance.signOut();
      Global.clearAccessToken(); // 글로벌 토큰 초기화
      initialUser = null;        // 사용자 상태 초기화
    }
  } else {
    Global.clearAccessToken();   // 로그인된 사용자가 없으면 토큰 초기화
    log('No authenticated user at startup');
  }

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "LifeFit",
      initialRoute: initialUser != null ? '/' : '/intro',
      // 초기 라우트 설정: 로그인 상태에 따라 홈 화면('/') 또는 인트로 화면('/intro')으로 이동
        routes: {
          '/' : (context) => const HomeScreen(),
          '/intro' : (context) => const Intro(),
          '/register' : (context) => const Register(),
        },
      theme: ThemeData(
        fontFamily: 'NanumSquareRound',
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(fontSize: 16 , color: Colors.grey),
          floatingLabelStyle: TextStyle(fontSize: 10),
          contentPadding: EdgeInsets.all(10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          )
        ),
      ),
      //home: Intro(),
      //home: HomeScreen(),
      //home: Calendar(),
    ),
  );
}


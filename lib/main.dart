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


void main() async {

  WidgetsFlutterBinding.ensureInitialized(); // 비동기 초기화 준비
  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await firebase_auth.FirebaseAuth.instance.setPersistence(firebase_auth.Persistence.LOCAL);
    log('Firebase initialized successfully');
  } catch (e) {
    log('Firebase initialization error: $e');
  }

  await initializeDateFormatting();

  // AuthController 초기화
  Get.put(AuthController());

  // Firebase 인증 상태 확인
  firebase_auth.User? initialUser;
  await for (var user in firebase_auth.FirebaseAuth.instance.authStateChanges().take(1)) {
    initialUser = user;
    break;
  }

  // 초기 토큰 캐싱: 로그인한 경우에만 실행
  if (initialUser != null) {
    try {
      await Global.updateAccessToken();
      log('Initial Firebase ID Token: ${Global.accessToken}');
    } catch (e) {
      log('Initial updateAccessToken error: $e');
      // 토큰 갱신 실패 시 로그아웃 처리
      await firebase_auth.FirebaseAuth.instance.signOut();
      Global.clearAccessToken();
      initialUser = null;
    }
  } else {
    Global.clearAccessToken();
    log('No authenticated user at startup');
  }

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "LifeFit",
      initialRoute: initialUser != null ? '/' : '/intro',
        // initialUser != null 일 때만 '/' 으로 이동. 로그아웃 후 /intro로 리다이렉트
        routes: {
          '/' : (context) => const HomeScreen(),
          '/intro' : (context) => const Intro(),
          '/register' : (context) => const Register(),
        },
      theme: ThemeData(
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


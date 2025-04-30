import 'package:get/get.dart';
import 'package:lifefit/provider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'dart:developer';
import 'package:lifefit/shared/global.dart';



class AuthController extends GetxController {
  final authProvider = Get.put(AuthProvider()); // lifefit의 AuthProvider 참조
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth
      .instance; // 별칭 사용

  // 아이디 유효성 검사
  String? validateId(String uid) {
    if (uid.isEmpty) {
      return '아이디를 입력해주세요';
    }
    if (uid.length < 4) {
      return '아이디는 4자 이상이어야 합니다';
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(uid)) {
      return '아이디는 영문자와 숫자만 사용할 수 있습니다';
    }
    return null;
  }

  // 비밀번호 유효성 검사
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (password.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password)) {
      return '비밀번호는 문자와 숫자를 모두 포함해야 합니다';
    }
    return null;
  }

  // 이름 유효성 검사
  String? validateName(String name) {
    if (name.isEmpty) {
      return '닉네임을 입력해주세요';
    }
    if (name.length < 2) {
      return '닉네임은 2자 이상이어야 합니다';
    }
    // 한글, 영문자만 허용, 조합 중인 한글도 허용
    if (!RegExp(r'^[a-zA-Z가-힣ᆞ-ᇿ]+$').hasMatch(name)) {
      return '닉네임은 한글 또는 영문자만 사용할 수 있습니다';
    }
    return null;
  }

  // 로그인 처리
  Future<bool> login(String uid, String password) async {
    try {
      // 아이디 유효성 검사
      String? uidError = validateId(uid);
      if (uidError != null) {
        Get.snackbar('오류', uidError, snackPosition: SnackPosition.TOP);
        return false;
      }

      // 비밀번호 유효성 검사
      String? passwordError = validatePassword(password);
      if (passwordError != null) {
        Get.snackbar('오류', passwordError, snackPosition: SnackPosition.TOP);
        return false;
      }

      // 서버 요청
      Map body = await authProvider.login(uid, password);
      if (body['result'] == 'ok') {
        if (body['custom_token'] == null || body['custom_token'].isEmpty) {
          Get.snackbar(
              '오류', '커스텀 토큰이 누락되었습니다', snackPosition: SnackPosition.TOP);
          return false;
        }
        String customToken = body['custom_token'];
        log("token : $customToken");

        // Firebase Authentication에 로그인
        await _auth.signInWithCustomToken(customToken);
        await Global.updateAccessToken(); // 토큰 캐싱
        log("Firebase ID Token: ${Global.accessToken}");
        Get.offAllNamed('/'); // 홈 화면으로 이동
        return true;
      } else {
        Get.snackbar('오류', body['message'] ?? '로그인에 실패했습니다',
            snackPosition: SnackPosition.TOP);
        return false;
      }
    } catch (e) {
      Get.snackbar('오류', '로그인 중 오류가 발생했습니다', snackPosition: SnackPosition.TOP);
      return false;
    }
  }

  // 회원가입 처리
  Future<bool> register(String uid, String password, String name,
      int? profile) async {
    try {
      // 아이디 유효성 검사
      String? uidError = validateId(uid);
      if (uidError != null) {
        Get.snackbar('오류', uidError, snackPosition: SnackPosition.TOP);
        return false;
      }

      // 비밀번호 유효성 검사
      String? passwordError = validatePassword(password);
      if (passwordError != null) {
        Get.snackbar('오류', passwordError, snackPosition: SnackPosition.TOP);
        return false;
      }

      // 이름 유효성 검사
      String? nameError = validateName(name);
      if (nameError != null) {
        Get.snackbar('오류', nameError, snackPosition: SnackPosition.TOP);
        return false;
      }

      // 서버에 회원가입 요청
      Map body = await authProvider.register(uid, password, name, profile);
      if (body['result'] == 'ok') {
        if (body['custom_token'] == null || body['custom_token'].isEmpty) {
          Get.snackbar(
              '오류', '커스텀 토큰이 누락되었습니다', snackPosition: SnackPosition.TOP);
          return false;
        }
        String customToken = body['custom_token'];
        log("token : $customToken");

        // Firebase Authentication에 로그인
        // Firebase Authentication에 로그인 (재시도 포함)
        int maxRetries = 2;
        int retryCount = 0;
        while (retryCount < maxRetries) {
          try {
            await _auth.signInWithCustomToken(customToken);
            log("signInWithCustomToken 성공");
            break;
          } catch (e) {
            retryCount++;
            log("signInWithCustomToken 시도 $retryCount 실패: $e");
            if (retryCount == maxRetries ||
                !e.toString().contains('network-request-failed')) {
              String errorMessage = 'Firebase 인증 오류';
              if (e.toString().contains('invalid-custom-token')) {
                errorMessage = '유효하지 않은 인증 토큰입니다';
              } else if (e.toString().contains('network-request-failed')) {
                errorMessage = '네트워크 연결을 확인해주세요';
              } else if (e.toString().contains('too-many-requests')) {
                errorMessage = '요청이 너무 많습니다. 잠시 후 다시 시도해주세요';
              }
              Get.snackbar(
                  '오류', errorMessage, snackPosition: SnackPosition.TOP);
              return false;
            }
            await Future.delayed(Duration(seconds: 1)); // 재시도 전 대기
          }
        }

        // 인증 상태 확인
        await Future.delayed(Duration(seconds: 1));
        if (_auth.currentUser == null) {
          log("Firebase user is null after signInWithCustomToken");
          Get.snackbar(
              '오류', 'Firebase 사용자 인증 실패', snackPosition: SnackPosition.TOP);
          return false;
        }
        log("Firebase user UID: ${_auth.currentUser!.uid}");

        // 토큰 캐싱
        try {
          await Global.updateAccessToken();
          log("Firebase ID Token: ${Global.accessToken}");
          if (Global.accessToken == null) {
            log("Access token is null after updateAccessToken");
            Get.snackbar('오류', 'ID 토큰 획득 실패', snackPosition: SnackPosition.TOP);
            return false;
          }
        } catch (e) {
          log("updateAccessToken 오류: $e");
          Get.snackbar('오류', '토큰 캐싱 오류: $e', snackPosition: SnackPosition.TOP);
          return false;
        }

        log("Navigating to home screen");
        Get.offAllNamed('/'); // 홈 화면으로 이동
        return true;
      } else {
        Get.snackbar('회원가입 에러', body['message'] ?? '회원가입에 실패했습니다',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      log("회원가입 전체 오류: $e");
      Get.snackbar(
          '오류', '회원가입 중 오류가 발생했습니다: $e', snackPosition: SnackPosition.TOP);
      return false;
    }
  }

  // 로그아웃 처리
  Future<bool> logout() async {
    try {
      // Firebase 로그아웃
      await _auth.signOut();
      log('Firebase signOut 성공');

      // 토큰 초기화
      Global.clearAccessToken();
      log('Access token cleared');

      // 로그인 화면으로 리다이렉트
      Get.offAllNamed('/intro'); // 또는 '/login'

      Get.snackbar('로그아웃', '성공적으로 로그아웃되었습니다', snackPosition: SnackPosition.TOP);
      return true;
    } catch (e) {
      log('로그아웃 오류: $e');
      Get.snackbar('오류', '로그아웃 중 오류가 발생했습니다: $e', snackPosition: SnackPosition.TOP);
      return false;
    }
  }
}
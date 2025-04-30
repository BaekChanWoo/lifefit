import 'package:firebase_auth/firebase_auth.dart';

// 로그인/회원가입 시 토큰을 갱신하고, 로그아웃 시 초기화하여 안정적으로 관리
class Global {

  static String? _accessToken; // 캐싱된 토큰
  static String? get accessToken => _accessToken;

  // 토큰 캐싱
  static Future<void> updateAccessToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser; // 현재 로그인된 사용자를 확인
      if (user == null) {  // 사용자가 없으면
        _accessToken = null;
        print('updateAccessToken: No authenticated user');
        return; // 예외 대신 정상 종료
      }
      _accessToken = await user.getIdToken(); // 사용자가 있으면 최신 ID 토큰을 가져옴
      if (_accessToken == null) {
        throw Exception('Failed to retrieve ID token');
      }
    } catch (e) {
      print('updateAccessToken error: $e');
      _accessToken = null;
      rethrow;
    }
  }

  // 로그아웃 시 호출
  static void clearAccessToken() {
    _accessToken = null;
  }

  // 애플리케이션에서 사용할 서버의 URL
  //static const String baseUrl = 'http://localhost:3000';
}
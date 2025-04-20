import 'package:get/get.dart';
import 'package:lifefit/provider/auth_provider.dart';


class AuthController extends GetxController {
  final AuthProvider authProvider = AuthProvider();

  // 아이디 유효성 검사
  String? validateId(String id) {
    if (id.isEmpty) {
      return '아이디를 입력해주세요';
    }
    if (id.length < 4) {
      return '아이디는 4자 이상이어야 합니다';
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(id)) {
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
  Future<bool> login(String id, String password) async {
    try {
      // 아이디 유효성 검사
      String? idError = validateId(id);
      if (idError != null) {
        Get.snackbar('오류', idError, snackPosition: SnackPosition.TOP);
        return false;
      }

      // 비밀번호 유효성 검사
      String? passwordError = validatePassword(password);
      if (passwordError != null) {
        Get.snackbar('오류', passwordError, snackPosition: SnackPosition.TOP);
        return false;
      }

      // 서버 요청 시뮬레이션
      // 유효성 통과 시 1초 대기
      await Future.delayed(const Duration(seconds: 1)); //
      return true; // 성공 가정
    } catch (e) {
      Get.snackbar('오류', '로그인 중 오류가 발생했습니다', snackPosition: SnackPosition.TOP);
      return false;
    }
  }

  // 회원가입 처리
  Future<bool> register(String id, String password, String name, int? profile) async {
    try {
      // 아이디 유효성 검사
      String? idError = validateId(id);
      if (idError != null) {
        Get.snackbar('오류', idError, snackPosition: SnackPosition.TOP);
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
      Map body = await authProvider.register(id, password, name, profile);
      if (body['result'] == 'ok') {
        return true; // 회원가입 성공
      }

      // 서버에서 반환한 에러 메시지 표시
      // 유효성 통과 시 authProvider.register 호출하여 서버에 요청
      Get.snackbar('회원가입 에러', body['message'] ?? '회원가입에 실패했습니다',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      Get.snackbar('오류', '회원가입 중 오류가 발생했습니다', snackPosition: SnackPosition.TOP);
      // 예외 발생 시 에러 메시지
      return false;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifefit/provider/auth_provider.dart';

// 홈 화면의 상태를 관리하는 GetX 컨트롤러
class HomeScreenController extends GetxController {
  final AuthProvider authProvider = Get.find<AuthProvider>();
  var userName = ''.obs; // 사용자 이름을 저장하는 반응형 변수
  var isFetching = false; // 중복 호출 방지 플래그
  var lastLoginTime = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserName(); // 화면 초기화 시 사용자 이름 가져오기

    // TODO: 서버로부터 실제 lastLoginTime을 받아서 세팅하거나,
    // 로그인 성공 직후에 아래처럼 현재 시간으로 설정.
    // lastLoginTime.value = fetchedLastLogin;

  }

  // 서버에서 사용자 이름을 가져오는 메서드
  Future<void> fetchUserName({int retryCount = 0}) async {
    if (isFetching) {
      print('Already fetching user profile, skipping...');
      return;
    }
    isFetching = true;
    try {
      final response = await authProvider.getUserProfile();
      print('User profile response: $response');
      if (response['result'] == 'ok' && response['data'] != null) {
        userName.value = response['data']['name'] ?? '사용자';
        print('User name set to: ${userName.value}');
      } else {
        if (retryCount < 3) {
          print('Retrying fetchUserName, attempt ${retryCount + 1}');
          await Future.delayed(Duration(seconds: 2));
          await fetchUserName(retryCount: retryCount + 1);
        } else {
          userName.value = '사용자';
          Get.snackbar(
            '오류',
            response['message'] ?? '사용자 정보를 가져오지 못했습니다',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
          );
          print('Error fetching user: ${response['message']}');
        }
      }
    } catch (e) {
      print('Fetch user error: $e');
      if (retryCount < 3) {
        print('Retrying fetchUserName, attempt ${retryCount + 1}');
        await Future.delayed(Duration(seconds: 2));
        await fetchUserName(retryCount: retryCount + 1);
      } else {
        userName.value = '사용자';
        Get.snackbar(
          '오류',
          '서버와의 통신 중 오류가 발생했습니다: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
    } finally {
      isFetching = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifefit/controller/auth_controller.dart';
import 'package:lifefit/const/colors.dart';
import 'package:intl/intl.dart';

class ProfileDetail extends StatefulWidget {
  const ProfileDetail({super.key});

  @override
  State<ProfileDetail> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  final AuthController authController = Get.find<AuthController>();
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await authController.authProvider.getUserProfile();
      print('프로필 응답: $response');

      if (response['result'] == 'ok' && response['data'] != null) {
        setState(() {
          userProfile = response['data'];
          isLoading = false;
        });
        print('프로필 키 목록: ${userProfile?.keys.toList()}');
        print('프로필 데이터: $userProfile');
      } else {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          '오류',
          response['message'] ?? '프로필 정보를 불러올 수 없습니다.',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        '오류',
        '프로필 정보를 불러오는 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '정보 없음';
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('yyyy년 MM월 dd일').format(date);
    } catch (e) {
      try {
        final parts = dateString.split('T')[0].split('-');
        if (parts.length == 3) {
          return '${parts[0]}년 ${parts[1]}월 ${parts[2]}일';
        }
      } catch (e2) {
        print('날짜 파싱 오류: $e2');
      }
      return '정보 없음';
    }
  }

  String _maskPassword(String? password) {
    if (password == null || password.isEmpty) return '정보 없음';
    return '*' * 8; // 실제 길이 대신 고정 길이로 표시
  }

  String _getValueSafely(String key, [String defaultValue = '정보 없음']) {
    if (userProfile == null) {
      if (key == 'uid') {
        return authController.userUid.value ?? defaultValue; // AuthController의 uid 사용
      }
      return defaultValue;
    }

    final possibleKeys = {
      'uid': ['uid', 'user_id', 'id', 'userId'],
      'name': ['name', 'username', 'user_name', 'nickname'],
      'password': ['password', 'pwd'],
      'created_at': ['created_at', 'createdAt', 'create_time', 'join_date', 'reg_date'],
      'profile_image': ['profile_image', 'profileImage', 'avatar', 'image'],
    };

    if (possibleKeys.containsKey(key)) {
      for (String possibleKey in possibleKeys[key]!) {
        if (userProfile!.containsKey(possibleKey) &&
            userProfile![possibleKey] != null &&
            userProfile![possibleKey].toString().isNotEmpty) {
          return userProfile![possibleKey].toString();
        }
      }
    }

    if (userProfile!.containsKey(key) &&
        userProfile![key] != null &&
        userProfile![key].toString().isNotEmpty) {
      return userProfile![key].toString();
    }

    if (key == 'uid') {
      return authController.userUid.value ?? defaultValue; // AuthController의 uid 대체
    }

    if (key == 'password') {
      return '비밀번호는 보안상 표시되지 않습니다';
    }

    return defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '프로필 정보',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: PRIMARY_COLOR,
        ),
      )
          : userProfile == null
          ? const Center(
        child: Text(
          '프로필 정보를 불러올 수 없습니다.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PRIMARY_COLOR.withOpacity(0.2),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 58,
                      backgroundImage: _getValueSafely('profile_image') != '정보 없음'
                          ? NetworkImage(_getValueSafely('profile_image'))
                          : const AssetImage('assets/img/mypageimg.jpg') as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getValueSafely('name', '사용자'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: PRIMARY_COLOR.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '@${_getValueSafely('uid', 'unknown')}',
                      style: TextStyle(
                        fontSize: 14,
                        color: PRIMARY_COLOR,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '계정 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: '아이디',
                    value: _getValueSafely('uid'),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.badge_outlined,
                    label: '이름',
                    value: _getValueSafely('name'),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.lock_outline,
                    label: '비밀번호',
                    value: _maskPassword(_getValueSafely('password')),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: '가입일',
                    value: _formatDate(_getValueSafely('created_at')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '돌아가기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: PRIMARY_COLOR.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: PRIMARY_COLOR,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
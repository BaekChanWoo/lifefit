import 'provider.dart';


class AuthProvider extends Provider{

  // 회원가입 요청
  Future<Map> register(String id, String password, String name, [int? profile]) async {
    try {
      // 서버에 POST 요청 전송(JSON 형태로 서버에 전송)
      final response = await post('/api/register', {
      'id' : id,
        'password' : password,
        'name' : name,
        'profile' : profile,
      });
      return response.body; // 서버 응답 반환
    } catch (e) {
      return { // 오류 시
        'result': 'error',
        'message': '서버와의 통신 중 오류가 발생했습니다'
      };
    }
  }

  // 로그인 요청
  Future<Map> login(String id, String password) async {
    try {
      // 서버에 POST 요청(아이디 , 비밀번호 전송)
      final response = await post('/api/login', {
        'id': id,
        'password': password,
      });
      return response.body; // 서버 응답 반환
    } catch (e) {
      return { // 오류시
        'result': 'error',
        'message': '서버와의 통신 중 오류가 발생했습니다'
      };
    }
  }
}
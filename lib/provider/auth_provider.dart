import 'provider.dart';


// Node.js 서버와의 인증 관련 http 요청
class AuthProvider extends Provider{

  // 회원가입 요청
  Future<Map> register(String uid, String password, String name, [int? profile_id]) async {
    try {
      // 서버에 POST 요청 전송(JSON 형태로 서버에 전송)
      final response = await post('/api/register', {
      'uid' : uid,
        'password' : password,
        'name' : name,
        'profile_id' : profile_id,
      });
      if (response.body == null) {
        return {'result': 'error', 'message': '서버 응답이 비어 있습니다'};
      }
      return response.body; // 서버 응답 반환
    } catch (e) {
      return { // 오류 시
        'result': 'error',
        'message': '서버와의 통신 중 오류가 발생했습니다'
      };
    }
  }

  // 로그인 요청
  Future<Map> login(String uid, String password) async {
    try {
      // 서버에 POST 요청(아이디 , 비밀번호 전송)
      final response = await post('/api/login', {
        'uid': uid,
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

  // 사용자 정보 조회 요청
  // 서버의 /api/user/my 엔드포인트를 호출하여 현재 로그인한 사용자의 정보를 가져옴
  Future<Map> getUserProfile() async {
    try{
      // 서버에 Get 요청
      final response = await get('/api/user/my');
      if(response.body == null){
        return {
          'result' : 'error',
          'message' : '서버 응답이 비어 있습니다'
        };
      }
      return response.body; // 서버 응답 반환
    } catch (e) {
      return {
        'result': 'error',
        'message': '서버와의 통신 중 오류 발생 : $e'
      };
    }
  }
}
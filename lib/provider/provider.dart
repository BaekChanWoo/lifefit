import 'package:get/get.dart';

class Provider extends GetConnect{

  // 기본 서버 주소 설정과 HTTP 헤더 설정등의 초기화 작업 수행
  @override
  void onInit(){
    allowAutoSignedCert = true; // 자체 서명된 SSL/TLS 인증서의 사용을 허용
    httpClient.baseUrl = '<http://localhost:3000>';
    httpClient.addRequestModifier<void>((request){
      request.headers['Accept'] = 'application/json'; // JSON 형식의 데이터 처리 가능
      return request;
    });
    super.onInit();

  }
}
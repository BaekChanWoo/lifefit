import 'package:get/get.dart';
import 'package:lifefit/shared/global.dart';
import 'package:flutter/foundation.dart';

class Provider extends GetConnect{

  // 기본 서버 주소 설정과 HTTP 헤더 설정등의 초기화 작업 수행
  @override
  void onInit(){
    allowAutoSignedCert = true; // 자체 서명된 SSL/TLS 인증서의 사용을 허용
    // httpClient.baseUrl = 'http://localhost:3000';
    // 실제 디바이스용: httpClient.baseUrl = 'http://192.168.x.x:3000';
    //httpClient.baseUrl = 'http://10.0.2.2:3000'; // 에뮬레이터용
    httpClient.baseUrl = kDebugMode ? 'http://10.0.2.2:3000' : 'http://your-server-ip:3000';
    httpClient.addRequestModifier<void>((request){    // Authorization 헤더 추가
      request.headers['Accept'] = 'application/json'; // JSON 형식의 데이터 처리 가능

      final token = Global.accessToken;
      if (token != null ) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });
    super.onInit();
  }

  // POST 요청 오버라이드: 401/403 에러 처리 및 재시도
  // 모든 HTTP 요청에 일관된 토큰 관리, 코드 중복 방지
  Future<Response<T>> post<T>(
      String? url,
      dynamic body, {
        String? contentType,
        Map<String, String>? headers,
        Map<String, dynamic>? query,
        Decoder<T>? decoder,
        Progress? uploadProgress,
        int retryCount = 1, // 재시도 횟수 제한
      }) async {
    print('Sending POST request to: $url, body: $body');
    try {
      final response = await super.post(
        url,
        body,
        contentType: contentType,
        headers: headers,
        query: query,
        decoder: decoder,
        uploadProgress: uploadProgress,
      );
      print('Response status: ${response.statusCode}, body: ${response.body}'); // 응답 디버깅
      // 401/403 에러 처리
      if ((response.statusCode == 401 || response.statusCode == 403) && retryCount > 0) {
        // 토큰 갱신
        await Global.updateAccessToken();

        // 재시도
        return await post(
          url,
          body,
          contentType: contentType,
          headers: headers,
          query: query,
          decoder: decoder,
          uploadProgress: uploadProgress,
          retryCount: retryCount - 1, // 재시도 횟수 감소
        );
      }

      return response;
    } catch (e) {
      print('Error during POST request: $e'); // 에러 디버깅
      throw Exception('서버와의 통신 중 오류가 발생했습니다: $e');
    }
  }
}


// Node.js 서버는 http://localhost:3000에서 구동되고 있다.
// Flutter 앱은 Android 에뮬레이터 또는 실제 디바이스에서 실행됨
// Android 에뮬레이터의 localhost는 에뮬레이터 자체를 가리킨다.
// 즉, 에뮬레이터에서 http://localhost:3000을 호출하면 에뮬레이터 내부의 포트 3000을 찾으려 한다
// 하지만 Node.js 서버는 에뮬레이터가 아니라 백찬우PC에서 실행 중이므로 연결이 실패

// Android 에뮬레이터는 호스트 PC 를 접근하가 위해 특수 IP 주소인 10.0.2.2를 사용한다
// 10.0.2.2는 에뮬레이터가 호스트 PC의 localhost로 매핑하는 가상 IP

// 에뮬레이터에서 http://10.0.2.2:3000을 호출하면, 이는 호스트(백찬우) PC의 http://loaclhost:3000으로 라우팅 됨
// 즉, http:10.0.2.2:3000은 Node.js 서버가 실행 중인 백찬우 PC의 포트 3000을 정확히 가르킵니다.
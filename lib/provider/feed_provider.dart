import 'package:get/get.dart';
import 'provider.dart';

class FeedProvider extends Provider{
  // 피드 리스트 (운동 목록)
  Future<Map> getList({int page = 1}) async {
    Response response = await get('/api/feed' , query: {'page' : '$page'}); // GET 요청
    print(response.statusCode);
    print(response.bodyString); // 피드의 목록을 담고 있는 배열 정보
    return response.body;
  }
  
}
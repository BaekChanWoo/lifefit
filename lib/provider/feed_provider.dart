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

  Future<Map> store(String title , String name , String content , int? image) async {
    final Map<String , dynamic> body ={
      'title' : title,
      'name' : name,
      'contetn' : content,
    };

    if(image != null){
      body['imageId'] = image.toString();
    }
    final response = await post('/api/feed', body);
    return response.body;
  }
  
}
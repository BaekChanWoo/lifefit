import 'package:lifefit/provider/provider.dart';

class FeedProvider extends Provider{

  static const String _baseFeedPath = '/api/feed';

  // 피드 목록 조회
  Future<Map<String, dynamic>> index({int page = 1, String? category}) async{
    final query = {'page': page.toString()};
    if (category != null && category.isNotEmpty) {
      query['category'] = category;
    }
    final response = await get('$_baseFeedPath', query: query);
    // 응답 바디가 Map<String, dynamic>이 아닌 경우 빈 맵 반환
    return response.body is Map<String, dynamic> ? response.body : {};
  }


  // 피드 생성. image_id는 선택적이며, user_id와 is_me를 포함.
  Future<Map<String, dynamic>> store(
      String title,
      String name,
      String content,
      int? imageId,
      String category,
      int userId, // userId 타입을 int로 유지
      ) async {
    final body = {
      'title': title,
      'name': name,
      'content': content,
      'category': category,
      'user_id': userId, // userId를 정수형 그대로 전달
      'is_me': true, // *** 이 부분을 다시 추가합니다 ***
      // imageId가 null이 아닐 경우에만 body에 추가
      // 이렇게 하면 imageId가 null일 때 'image_id' 키 자체가 요청 body에 포함되지 않습니다.
      // 이는 서버에서 image_id가 선택적 필드임을 처리하는 데 문제가 없습니다.
      if (imageId != null) 'image_id': imageId,
    };
    // imageId도 서버에서 정수로 받는다면 .toString()을 제거하는 것이 좋습니다.
    // 현재 서버 controller.js의 validateInput에서는 image_id 타입을 검사하지 않지만,
    // repository.js의 create 함수에서는 image_id || null 로 처리하므로, 정수 또는 null이 적합합니다.
    // Flutter에서 imageId가 null일 수 있으므로, 서버로 보낼 때도 null이면 포함하지 않거나 null로 보내야 합니다.
    // 만약 imageId를 항상 문자열로 보내야 한다면, 서버측 검증 로직도 수정이 필요할 수 있습니다.
    // 여기서는 imageId도 정수형으로 가정하고 수정합니다.

    // if (imageId != null) {
    //   body['image_id'] = imageId;
    // }

    final response = await post('$_baseFeedPath', body);
    return response.body is Map<String, dynamic> ? response.body : {};
  }

  // 피드 수정
  Future<Map<String, dynamic>> update(
      int id,
      String title,
      String content,
      int? imageId,
      String category,
      String name
      ) async {
    final body = {
      'title': title,
      'name': name,
      'content': content,
      'category': category,
      // 'is_me'는 일반적으로 생성 시에만 사용하고, 수정 시에는 변경하지 않거나 다른 로직이 필요할 수 있습니다.
      // 만약 수정 시에도 'is_me'를 보내야 한다면 여기에 추가해야 합니다.
      // 여기서는 생성(store)에만 집중하므로 그대로 둡니다.
      if (imageId != null) 'image_id': imageId,
    };

    // if (imageId != null) {
    //   body['image_id'] = imageId;
    // }
    final response = await put('$_baseFeedPath/$id', body);
    return response.body is Map<String, dynamic> ? response.body : {};
  }

  // 피드 상세 조회
  Future<Map<String, dynamic>> show(int id) async {
    final response = await get('$_baseFeedPath/$id');
    // return response.body is Map<String, dynamic> ? response.body : {};
    return response.body;
  }

  // 피드 삭제
  Future<Map<String, dynamic>> destroy(int id) async {
    final response = await delete('$_baseFeedPath/$id');
    // return response.body is Map<String, dynamic> ? response.body : {};
    return response.body;
  }

}
import 'dart:math';
import 'package:get/get.dart';
import 'package:lifefit/model/feed_model.dart';
import 'package:lifefit/provider/feed_provider.dart';


class FeedController extends GetxController{
  final feedProvider = Get.put(FeedProvider());
  RxList<FeedModel> feedList = <FeedModel>[].obs;
  final Rx<FeedModel?> currentFeed = Rx<FeedModel?>(null);

  // feedList에 새항복을 추가
  Future<bool> feedCreate(
      String title, String name, String content, int? image) async {
    Map body = await feedProvider.store(title, name, content, image);
    if (body['result'] == 'ok') {
      // 새로운 FeedModel 생성 및 feedList에 추가
      final newFeed = FeedModel.parse({
        'id' : DateTime.now().millisecondsSinceEpoch, // 임시 ID
        'title' : title,
        'name' : name,
        'content' : content,
        'image' : image,
      });
      feedList.add(newFeed); // 반응형 리스트에 추가
      //await feed(); // 피드 작성 후 목록을 새로 고침
      return true;
    }
    Get.snackbar('생성 에러', body['message'], snackPosition: SnackPosition.BOTTOM);
    return false;
  }

  /*
  @override
  void onInit(){
    super.onInit();
    _initialData();
  }
  _initialData() {
    List<Map> sample = [
      {'id': 1, 'title': '러닝은 무조건', 'content': '1시간 이상 해요', "name": "백찬우"},
      {'id': 2, 'title': '필라테스는 이렇게', 'content': '몸풀기 꼭!', "name": "차예빈"},
      {'id': 3, 'title': '농구 레이업', 'content': '몸풀기 꼭!', "name": "조성준"},
      {'id': 4, 'title': '헬스는 이렇게', 'content': '몸풀기 꼭!', "name": "이예린"},
    ];

    feedList.assignAll(sample);
  }
  */

  // 페이지 번호에 따라 데이터를 새로 고침하거나, 추가 데이터를 로드
  // 피드 목록을 가져오는 역활
  /*
  feedIndex({int page = 1}) async {
    Map json = await feedProvider.index(page: page);
    List<FeedModel> tmp =
    json['data'].map<FeedModel>((m) => FeedModel.parse(m)).toList();
    (page == 1) ? feedList.assignAll(tmp) : feedList.addAll(tmp);
  }
  */

  void addDate(){
    final random = Random();
    final newItem = FeedModel.parse({
      'id': random.nextInt(100),
      'title': '제목 ${random.nextInt(100)}',
      'content': '설명 ${random.nextInt(100)}',
      'name' : '이름 ${random.nextInt(100)}',
    });

    feedList.add(newItem); // feedList에 새 항목 추가
  }

  void updateData(FeedModel updatedItem){
    final index = feedList.indexWhere((item) => item.id == updatedItem.id);
    if(index != -1){
      feedList[index] = updatedItem;
    }
  }

}
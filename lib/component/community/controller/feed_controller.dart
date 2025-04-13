import 'dart:math';
import 'package:get/get.dart';

class FeedController extends GetxController{
  RxList<Map> feedList = <Map>[].obs;

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
  void addDate(){
    final random = Random();
    final newItem = {
      'id': random.nextInt(100),
      'title': '제목 ${random.nextInt(100)}',
      'content': '설명 ${random.nextInt(100)}',
      'name' : '이름 ${random.nextInt(100)}',
    };

    feedList.add(newItem); // feedList에 새 항목 추가
  }

  void updateData(Map newDate){
    final id = newDate['id'];
    final index = feedList.indexWhere((item) => item['id'] == id);
    if(index != -1){
      feedList[index] = newDate;
    }
  }

}
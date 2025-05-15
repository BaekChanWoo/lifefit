import 'package:get/get.dart';
import 'package:lifefit/model/feed_model.dart';
import 'package:lifefit/provider/feed_provider.dart';
import 'dart:developer' as developer;


class FeedController extends GetxController{
  final feedProvider = Get.put(FeedProvider());
  RxList<FeedModel> feedList = <FeedModel>[].obs;
  final Rx<FeedModel?> currentFeed = Rx<FeedModel?>(null);
  final RxString selectedCategory = ''.obs; // 빈 문자열로 초기화 (전체 보기)
  final RxBool isLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    feedIndex(); // 컨트롤러 초기화 시 데이터 로딩
  }

  // 피드 목록을 가져옵니다. page가 1이면 목록을 새로고침하고, 그렇지 않으면 추가 로드합니다.
  // 첫 페이지를 새로 고침할 때는 assignAll을 사용하여 기존 목록을 새 데이터로 교체
  Future<void> feedIndex({int page = 1, String? category}) async {
    try {
      isLoading.value = true;
      final response = await feedProvider.index(page: page, category: category);
      isLoading.value = false;

      developer.log('feedIndex response: $response', name: 'FeedController');

      if (_isSuccessResponse(response)) {
        final List<dynamic> data = response['data'] ?? [];
        final newFeeds = data.map((m) => FeedModel.parse(m)).toList();

        if (page == 1) {
          feedList.assignAll(newFeeds);
        } else {
          feedList.addAll(newFeeds);
        }

        if (newFeeds.isEmpty && page == 1) {
          Get.snackbar(
            '알림',
            category != null ? '$category 카테고리에 게시물이 없습니다.' : '게시물이 없습니다.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        _handleError(page, response['message']?.toString() ?? '피드를 불러오지 못했습니다.');
      }
    } catch (e) {
      isLoading.value = false;
      _handleError(page, '서버에 연결할 수 없습니다: $e');
    }
  }


  // feedList에 새항복을 추가
  // 피드 생성
  // 새 피드를 생성하고 목록에 추가합니다.
  Future<bool> feedCreate(String title, String name, String content, int? imageId, String category, int userId) async {
    try {
      final response = await feedProvider.store(title, name, content, imageId, category, userId);
      developer.log('feedCreate response: $response', name: 'FeedController');

      if (_isSuccessResponse(response)) {
        final newFeed = FeedModel.parse({
          'id': response['data'] ?? 0,
          'title': title,
          'name': name,
          'content': content,
          'image_id': imageId,
          'image_path': imageId != null && response['image_path']?.isNotEmpty == true ? response['image_path'] : null,
          'category': category,
          'created_at': DateTime.now().toIso8601String(),
          'is_me': true,
          'writer': {'id': userId}, // UserModel에 user_id 반영
        });
        feedList.insert(0, newFeed);
        return true;
      } else {
        Get.snackbar('생성 에러', response['message']?.toString() ?? '게시물 생성에 실패했습니다.', snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('네트워크 에러', '서버에 연결할 수 없습니다: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  // 피드 수정
  // 기존 피드를 수정합니다.
  Future<bool> feedUpdate(int id, String title, String content, int? imageId, String category, String name) async {
    try {
      final response = await feedProvider.update(id, title, content, imageId, category, name);
      developer.log('feedUpdate response: $response', name: 'FeedController');

      if (_isSuccessResponse(response)) {
        final index = feedList.indexWhere((feed) => feed.id == id);
        if (index != -1) {
          feedList[index] = feedList[index].copyWith(
            title: title,
            content: content,
            imageId: imageId,
            imagePath: imageId != null && response['image_path']?.isNotEmpty == true ? response['image_path'] : null,
            category: category,
            name: name,
          );
          feedList.refresh();
        }
        return true;
      } else {
        Get.snackbar('수정 에러', response['message']?.toString() ?? '게시물 수정에 실패했습니다.', snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('네트워크 에러', '서버에 연결할 수 없습니다: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  // 피드 상세 조회
  // 특정 피드의 상세 정보를 조회합니다.
  Future<void> feedShow(int id) async {
    try {
      final response = await feedProvider.show(id);
      developer.log('feedShow response: $response', name: 'FeedController');

      if (_isSuccessResponse(response)) {
        currentFeed.value = FeedModel.parse(response['data'] ?? {});
      } else {
        Get.snackbar('조회 에러', response['message']?.toString() ?? '피드 정보를 불러오지 못했습니다.', snackPosition: SnackPosition.BOTTOM);
        currentFeed.value = null;
      }
    } catch (e) {
      Get.snackbar('네트워크 에러', '서버에 연결할 수 없습니다: $e', snackPosition: SnackPosition.BOTTOM);
      currentFeed.value = null;
    }
  }

  // 피드를 삭제합니다.
  Future<bool> feedDelete(int id) async {
    try {
      final response = await feedProvider.destroy(id);
      developer.log('feedDelete response: $response', name: 'FeedController');

      if (_isSuccessResponse(response)) {
        feedList.removeWhere((feed) => feed.id == id);
        return true;
      } else {
        Get.snackbar('삭제 에러', response['message']?.toString() ?? '게시물 삭제에 실패했습니다.', snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('네트워크 에러', '서버에 연결할 수 없습니다: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  bool _isSuccessResponse(Map<String, dynamic> response) {
    final result = response['result']?.toString().toLowerCase();
    return result == 'success' || result == '성공' || result == 'ok';
  }

  void _handleError(int page, String message) {
    if (page == 1) {
      feedList.clear();
      Get.snackbar('오류', message, snackPosition: SnackPosition.BOTTOM);
    }
  }

}
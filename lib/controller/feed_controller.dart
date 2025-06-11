import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lifefit/model/feed_model.dart';
import 'package:lifefit/provider/feed_provider.dart';
import 'dart:developer' as developer;
import 'package:lifefit/model/comment_model.dart';


class FeedController extends GetxController{
  final feedProvider = Get.put(FeedProvider());

  final RxList<FeedModel> feedList = <FeedModel>[].obs;
  final Rx<FeedModel?> currentFeed = Rx<FeedModel?>(null);
  final RxString selectedCategory = ''.obs; // 빈 문자열로 초기화 (전체 보기)
  final RxBool isLoading = false.obs;
  final RxList<FeedModel> searchList = <FeedModel>[].obs;

  RxBool isLiked = false.obs;
  RxInt likeCount = 0.obs;
  RxList<CommentModel> comments = <CommentModel>[].obs;


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

      // 카테고리가 빈 문자열이면 null로 처리
      final effectiveCategory = (category != null && category.isNotEmpty) ? category : null;
      final response = await feedProvider.index(page: page, category: effectiveCategory);

      isLoading.value = false;

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
        //_handleError(page, response['message']?.toString() ?? '피드를 불러오지 못했습니다.');
        Get.snackbar('조회 에러', response['message']?.toString() ?? '피드를 불러오지 못했습니다.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      isLoading.value = false;
      //_handleError(page, '서버에 연결할 수 없습니다: $e');
      Get.snackbar('네트워크 에러', '서버에 연결할 수 없습니다: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }


  searchIndex(String keyword , {int page = 1 }) async{
    Map json = await feedProvider.index(page : page , keyword: keyword);
    List<FeedModel> tmp =
        json['data'].map<FeedModel>((m) => FeedModel.parse(m)).toList();
    (page == 1) ? searchList.assignAll(tmp) : searchList.addAll(tmp);
  }


  // feedList에 새항복을 추가
  // 피드 생성
  // 새 피드를 생성하고 목록에 추가합니다.
  Future<bool> feedCreate(String title, String name, String content, int? imageId, String category, int userId) async {

    // 카테고리가 null이나 빈 문자열이면 기본값 '기타' 사용
    final finalCategory = category.isNotEmpty ? category : '기타';

    developer.log('feedCreate called with category: $category', name: 'FeedController');
    try {
      final response = await feedProvider.store(title, name, content, imageId, finalCategory, userId);
      developer.log('feedCreate response: $response', name: 'FeedController');

      if (_isSuccessResponse(response)) {
        final newFeed = FeedModel.parse({
          'id': response['data'] ?? 0,
          'title': title,
          'name': name,
          'content': content,
          'image_id': imageId,
          'image_path': imageId != null && response['image_path'] != null ? response['image_path'] : null,
          'category': finalCategory,
          'created_at': DateTime.now().toIso8601String(),
          'is_me': true,
          'writer': {'id': userId}, // UserModel에 user_id 반영(게시물 작성자 ID)
          'like_count': 0, // 새 게시물은 좋아요 0개
          'liked_by_me': false, // 새 게시물은 내가 좋아요 누르지 않음
        });

        // 빌드 완료 후 feedList 업데이트
        WidgetsBinding.instance.addPostFrameCallback((_) {
          feedList.insert(0, newFeed);
          feedList.refresh(); // Obx가 변경을 감지하도록 명시적 새로고침
        });
        return true;
      } else {
        Get.snackbar('생성 에러', response['message']?.toString() ?? '게시물 생성에 실패했습니다.', snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      // Get.snackbar('네트워크 에러', '서버에 연결할 수 없습니다: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  // 피드 수정
  // 기존 피드를 수정합니다.
  Future<bool> feedUpdate(int id, String title, String content, int? imageId, String category, String name) async {

    // 카테고리가 null이나 빈 문자열이면 기본값 '기타' 사용
    final finalCategory = category.isNotEmpty ? category : '기타';

    try {
      final response = await feedProvider.update(id, title, content, imageId, finalCategory, name);
      developer.log('feedUpdate response: $response', name: 'FeedController');

      if (_isSuccessResponse(response)) {
        final index = feedList.indexWhere((feed) => feed.id == id);
        if (index != -1) {
          feedList[index] = feedList[index].copyWith(
            title: title,
            content: content,
            imageId: imageId,
            imagePath: imageId != null && response['image_path'] != null ? response['image_path'] : null,
            category: finalCategory,
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
      // developer.log('feedShow response: $response', name: 'FeedController');

      if (_isSuccessResponse(response)) {
        // 1) 데이터 파싱
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final feed = FeedModel.parse(data);

        // 2) currentFeed 갱신
        currentFeed.value = feed;

        // 3) 좋아요·댓글 상태 갱신
        likeCount.value = feed.likeCount;
        isLiked.value = feed.likedByMe;
        comments.assignAll(feed.comments);
      } else {
        Get.snackbar(
          '조회 에러',
          response['message']?.toString() ?? '피드 정보를 불러오지 못했습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
        currentFeed.value = null;
      }
    } catch (e) {
      Get.snackbar(
        '네트워크 에러',
        '서버에 연결할 수 없습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
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

  Future<void> toggleLike() async {
    final r = await feedProvider.like(currentFeed.value!.id);
    likeCount.value = r['data']['count'];
    isLiked.value = r['data']['liked'];

    // feedList에서 해당 피드도 업데이트
    final feedIndex = feedList.indexWhere((feed) => feed.id == currentFeed.value!.id);
    if (feedIndex != -1) {
      feedList[feedIndex] = feedList[feedIndex].copyWith(
        likeCount: r['data']['count'],
        likedByMe: r['data']['liked'],
      );
      feedList.refresh(); // 리스트 새로고침 트리거
    }

    // currentFeed도 업데이트
    if (currentFeed.value != null) {
      currentFeed.value = currentFeed.value!.copyWith(
        likeCount: r['data']['count'],
        likedByMe: r['data']['liked'],
      );
    }
  }

  Future<void> loadComments() async {
    final r = await feedProvider.getComments(currentFeed.value!.id);
    comments.assignAll((r['data'] as List).map((m) => CommentModel.fromJson(m)).toList());
  }

  Future<void> postComment(String content) async {
    final r = await feedProvider.addComment(currentFeed.value!.id, content);
    final newComment = CommentModel.fromJson(r['data']);
    comments.add(newComment);

    // feedList에서 해당 피드의 댓글 수도 업데이트
    final feedIndex = feedList.indexWhere((feed) =>
    feed.id == currentFeed.value!.id);
    if (feedIndex != -1) {
      final updatedComments = List<CommentModel>.from(
          feedList[feedIndex].comments)
        ..add(newComment);
      feedList[feedIndex] =
          feedList[feedIndex].copyWith(comments: updatedComments);
      feedList.refresh();
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

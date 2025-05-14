// youtube_model.dart
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // FutureOr 사용을 위해 import
import 'dart:developer';

class YoutubeSearchResponse {
  String kind;
  String etag;
  String? nextPageToken;
  List<SearchItem> items;
  PageInfo pageInfo;

  YoutubeSearchResponse({
    required this.kind,
    required this.etag,
    this.nextPageToken,
    required this.items,
    required this.pageInfo,
  });

  factory YoutubeSearchResponse.fromJson(dynamic json) {
    var list = json['items'] as List;

    return YoutubeSearchResponse(
      kind: json['kind'] == null ? '' : json['kind'] as String,
      etag: json['etag'] == null ? '' : json['etag'] as String,
      nextPageToken: json['nextPageToken'] as String?,
      items: list.isNotEmpty ? list.map((i) => SearchItem.fromJson(i)).toList() : [],
      pageInfo: PageInfo.fromJson(json['pageInfo']),
    );
  }
}

class PageInfo {
  int totalResults;
  int resultsPerPage;

  PageInfo({required this.totalResults, required this.resultsPerPage});

  factory PageInfo.fromJson(dynamic json) {
    return PageInfo(
      totalResults: json['totalResults'] == null ? 0 : json['totalResults'] as int,
      resultsPerPage: json['resultsPerPage'] == null ? 0 : json['resultsPerPage'] as int,
    );
  }
}

class SearchItem {
  String kind;
  String etag;
  Id id;
  Snippet snippet;

  SearchItem({required this.kind, required this.etag, required this.id, required this.snippet});

  factory SearchItem.fromJson(dynamic json) {
    return SearchItem(
      kind: json['kind'] == null ? '' : json['kind'] as String,
      etag: json['etag'] == null ? '' : json['etag'] as String,
      id: Id.fromJson(json['id']),
      snippet: Snippet.fromJson(json['snippet']),
    );
  }
}

class Id {
  String kind;
  String? videoId;
  String? channelId;
  String? playlistId;

  Id({required this.kind, this.videoId, this.channelId, this.playlistId});

  factory Id.fromJson(dynamic json) {
    return Id(
      kind: json['kind'] == null ? '' : json['kind'] as String,
      videoId: json['videoId'] as String?,
      channelId: json['channelId'] as String?,
      playlistId: json['playlistId'] as String?,
    );
  }
}

class Snippet {
  String? publishedAt;
  String? channelId;
  String title;
  String? description;
  Thumbnails? thumbnails;
  String? channelTitle;
  String? liveBroadcastContent;
  DateTime? publishTime;

  Snippet({
    this.publishedAt,
    this.channelId,
    required this.title,
    this.description,
    this.thumbnails,
    this.channelTitle,
    this.liveBroadcastContent,
    this.publishTime,
  });

  factory Snippet.fromJson(dynamic json) {
    return Snippet(
      publishedAt: json['publishedAt'] as String?,
      channelId: json['channelId'] as String?,
      title: json['title'] == null ? '' : json['title'] as String,
      description: json['description'] as String?,
      thumbnails: json['thumbnails'] == null ? null : Thumbnails.fromJson(json['thumbnails']),
      channelTitle: json['channelTitle'] as String?,
      liveBroadcastContent: json['liveBroadcastContent'] as String?,
      publishTime: json['publishTime'] == null ? null : DateTime.parse(json['publishTime'] as String),
    );
  }
}

class Thumbnails {
  Thumbnail? default_;
  Thumbnail? medium;
  Thumbnail? high;
  Thumbnail? standard;
  Thumbnail? maxres;

  Thumbnails({this.default_, this.medium, this.high, this.standard, this.maxres});

  factory Thumbnails.fromJson(dynamic json) {
    return Thumbnails(
      default_: json['default'] == null ? null : Thumbnail.fromJson(json['default']),
      medium: json['medium'] == null ? null : Thumbnail.fromJson(json['medium']),
      high: json['high'] == null ? null : Thumbnail.fromJson(json['high']),
      standard: json['standard'] == null ? null : Thumbnail.fromJson(json['standard']),
      maxres: json['maxres'] == null ? null : Thumbnail.fromJson(json['maxres']),
    );
  }
}

class Thumbnail {
  String? url;
  int? width;
  int? height;

  Thumbnail({this.url, this.width, this.height});

  factory Thumbnail.fromJson(dynamic json) {
    return Thumbnail(
      url: json['url'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }
}

class SearchVideoItem {
  final String title;
  final String thumbnailUrl;
  final String channelName;
  final String videoId;

  SearchVideoItem({
    required this.title,
    required this.thumbnailUrl,
    required this.channelName,
    required this.videoId,
  });

  factory SearchVideoItem.fromSearchItem(SearchItem item) {
    return SearchVideoItem(
      title: item.snippet.title,
      thumbnailUrl: item.snippet.thumbnails?.medium?.url ?? '',
      channelName: item.snippet.channelTitle ?? '',
      videoId: item.id.videoId ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'channelName': channelName,
      'videoId': videoId,
    };
  }

  factory SearchVideoItem.fromJson(Map<String, dynamic> json) {
    return SearchVideoItem(
      title: json['title'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      channelName: json['channelName'] as String,
      videoId: json['videoId'] as String,
    );
  }
}

// 실ㅈㅔ API 키
const List<String> YOUTUBE_API_KEYS =
['AIzaSyC9_2ZsXAZqV-liahgGDOGVTCUCFQqUm3M', 'AIzaSyAQqh4fHbI1TFiVpE57p7wQ8retNDzBsBU'];
int _currentApiKeyIndex = 0;

// Firebase Firestore 인스턴스
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
const String _cacheCollection = 'youtube_search_cache';
const Duration _cacheDuration = Duration(minutes: 50); // 캐시 유지 시간

Future<List<SearchVideoItem>> fetchYoutubeListWithDio(String keyword) async {

  //  Firebase 캐시에서 데이터 조회
  final cachedData = await _firestore.collection(_cacheCollection).doc(keyword).get();

  if (cachedData.exists &&
      cachedData.data()?['expiryTime'] != null &&
      (cachedData.data()!['expiryTime'] as Timestamp).toDate().isAfter(DateTime.now()) &&
      cachedData.data()?['items'] != null) {
    log('Firebase 캐시에서 결과 사용: $keyword', name: 'YoutubeSearchService');
    final List<dynamic> cachedItems = cachedData.data()!['items'] as List<dynamic>;
    return cachedItems.map((item) => SearchVideoItem.fromJson(item)).toList();
  }

  //  캐시가 없거나 만료시 YouTube API 호출
  String currentApiKey = YOUTUBE_API_KEYS[_currentApiKeyIndex % YOUTUBE_API_KEYS.length];
  var part = 'snippet';
  var maxResults = 10;
  var dio = Dio();

  try {
    final response = await dio.get(
      'https://www.googleapis.com/youtube/v3/search',
      queryParameters: {
        'part': part,
        'q': keyword,
        'maxResults': maxResults,
        'key': currentApiKey,
      },
    );

    if (response.statusCode == 200) {
      final decodedData = response.data as Map<String, dynamic>;
      final youtubeSearchResponse = YoutubeSearchResponse.fromJson(decodedData);
      final searchResults = youtubeSearchResponse.items.map((item) => SearchVideoItem.fromSearchItem(item).toJson()).toList();

      // 3. Firebase 캐시에 데이터 저장
      await _firestore.collection(_cacheCollection).doc(keyword).set({
        'items': searchResults,
        'expiryTime': Timestamp.fromDate(DateTime.now().add(_cacheDuration)),
      });
      return searchResults.map((item) => SearchVideoItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load YouTube search result: ${response.statusCode}');
    }
  } catch (e) {
    if (e is DioException && e.response?.statusCode == 403) {
      final errorMessage = e.response?.data?['error']?['message']?.toString();
      if (errorMessage != null && errorMessage.contains('quotaExceeded')) {
        log('할당량 초과, 다음 키로 전환', name: 'YoutubeSearchService', level: 1);
        _currentApiKeyIndex++;
        // 재시도 (한 번만)
        String currentApiKey = YOUTUBE_API_KEYS[_currentApiKeyIndex % YOUTUBE_API_KEYS.length];
        try {
          final response = await dio.get(
            'https://www.googleapis.com/youtube/v3/search',
            queryParameters: {
              'part': part,
              'q': keyword,
              'maxResults': maxResults,
              'key': currentApiKey,
            },
          );
          if (response.statusCode == 200) {
            final decodedData = response.data as Map<String, dynamic>;
            final youtubeSearchResponse = YoutubeSearchResponse.fromJson(decodedData);
            final searchResults = youtubeSearchResponse.items.map((item) => SearchVideoItem.fromSearchItem(item).toJson()).toList();
            await _firestore.collection(_cacheCollection).doc(keyword).set({
              'items': searchResults,
              'expiryTime': Timestamp.fromDate(DateTime.now().add(_cacheDuration)),
            });
            return searchResults.map((item) => SearchVideoItem.fromJson(item)).toList();
          } else {
            throw Exception('Failed to load YouTube search result (after retry): ${response.statusCode}');
          }
        } catch (retryE) {
          throw Exception('YouTube API 재시도 실패: $retryE');
        }
      }
    }
    throw Exception('Failed to load YouTube search result with Dio: $e');
  } finally {
    dio.close();
  }
}
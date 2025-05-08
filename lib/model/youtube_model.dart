import 'package:dio/dio.dart';

class YoutubeSearchResponse {
  String kind;
  String etag;
  String nextPageToken;
  List<SearchItem> items;
  PageInfo pageInfo;

  YoutubeSearchResponse({
    required this.kind,
    required this.etag,
    required this.nextPageToken,
    required this.items,
    required this.pageInfo,
  });

  factory YoutubeSearchResponse.fromJson(dynamic json) {
    var list = json['items'] as List;

    return YoutubeSearchResponse(
      kind: json['kind'] == null ? '' : json['kind'] as String,
      etag: json['etag'] == null ? '' : json['etag'] as String,
      nextPageToken: json['nextPageToken'] == null ? '' : json['nextPageToken'] as String,
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
  String videoId;

  Id({required this.kind, required this.videoId});

  factory Id.fromJson(dynamic json) {
    return Id(
      kind: json['kind'] == null ? '' : json['kind'] as String,
      videoId: json['videoId'] == null ? '' : json['videoId'] as String,
    );
  }
}

class Snippet {
  String publishedAt;
  String channelId;
  String title;
  String description;
  Thumbnails thumbnails;
  String channelTitle;
  String liveBroadcastContent;
  DateTime publishTime;

  Snippet({
    required this.publishedAt,
    required this.channelId,
    required this.title,
    required this.description,
    required this.thumbnails,
    required this.channelTitle,
    required this.liveBroadcastContent,
    required this.publishTime,
  });

  factory Snippet.fromJson(dynamic json) {
    return Snippet(
      publishedAt: json['publishedAt'] == null ? '' : json['publishedAt'] as String,
      channelId: json['channelId'] == null ? '' : json['channelId'] as String,
      title: json['title'] == null ? '' : json['title'] as String,
      description: json['description'] == null ? '' : json['description'] as String,
      thumbnails: Thumbnails.fromJson(json['thumbnails']),
      channelTitle: json['channelTitle'] == null ? '' : json['channelTitle'] as String,
      liveBroadcastContent: json['liveBroadcastContent'] == null ? '' : json['liveBroadcastContent'] as String,
      publishTime: json['publishTime'] == null ? DateTime.now() : DateTime.parse(json['publishTime'] as String),
    );
  }
}

class Thumbnails {
  Thumbnail default_;
  Thumbnail medium;
  Thumbnail high;

  Thumbnails({required this.default_, required this.medium, required this.high});

  factory Thumbnails.fromJson(dynamic json) {
    return Thumbnails(
      default_: Thumbnail.fromJson(json['default']),
      medium: Thumbnail.fromJson(json['medium']),
      high: Thumbnail.fromJson(json['high']),
    );
  }
}

class Thumbnail {
  String url;
  int width;
  int height;

  Thumbnail({required this.url, required this.width, required this.height});

  factory Thumbnail.fromJson(dynamic json) {
    return Thumbnail(
      url: json['url'] == null ? '' : json['url'] as String,
      width: json['width'] == null ? 0 : json['width'] as int,
      height: json['height'] == null ? 0 : json['height'] as int,
    );
  }
}

class SearchVideoItem {
  final String title;
  final String thumbnailUrl;
  final String channelName;
  final String videoId;

  SearchVideoItem({required this.title, required this.thumbnailUrl, required this.channelName, required this.videoId});

  factory SearchVideoItem.fromSearchItem(SearchItem item) {
    return SearchVideoItem(
      title: item.snippet.title,
      thumbnailUrl: item.snippet.thumbnails.medium.url,
      channelName: item.snippet.channelTitle,
      videoId: item.id.videoId,
    );
  }
}

late Future<List<SearchVideoItem>> youtubeList;

@override
void initState() {
  // super.initState(); // initState는 StatefulWidget 사용
  // youtubeList = fetchYoutubeListWithDio('검색하고싶은 키워드');
}

Future<List<SearchVideoItem>> fetchYoutubeListWithDio(String keyword) async {
  var part = 'snippet';
  var maxResults = 10; // 불러오는 개수
  var key = 'AIzaSyC9_2ZsXAZqV-liahgGDOGVTCUCFQqUm3M'; //  실제 API 키

  var dio = Dio();
  try {
    var response = await dio.get(
      'https://www.googleapis.com/youtube/v3/search', // 키워드 검색 엔드포인트
      queryParameters: {
        'part': part,
        'q': keyword, // 검색어 파라미터 추가
        'maxResults': maxResults,
        'key': key,
      },
    );

    if (response.statusCode == 200) {
      var decodedData = response.data;
      final youtubeSearchResponse = YoutubeSearchResponse.fromJson(decodedData);
      return youtubeSearchResponse.items.map((item) => SearchVideoItem.fromSearchItem(item)).toList();
    } else {
      throw Exception('Failed to load YouTube search result: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to load YouTube search result with Dio: $e');
  } finally {
    dio.close();
  }
}
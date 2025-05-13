class SearchListResponse {
  final String kind;
  final String etag;
  final String? nextPageToken;
  final String regionCode;
  final PageInfo pageInfo;
  final List<SearchResult> items;

  SearchListResponse({
    required this.kind,
    required this.etag,
    this.nextPageToken,
    required this.regionCode,
    required this.pageInfo,
    required this.items,
  });

  factory SearchListResponse.fromJson(Map<String, dynamic> json) {
    return SearchListResponse(
      kind: json['kind'] as String,
      etag: json['etag'] as String,
      nextPageToken: json['nextPageToken'] as String?,
      regionCode: json['regionCode'] as String,
      pageInfo: PageInfo.fromJson(json['pageInfo'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((item) => SearchResult.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PageInfo {
  final int totalResults;
  final int resultsPerPage;

  PageInfo({
    required this.totalResults,
    required this.resultsPerPage,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      totalResults: json['totalResults'] as int,
      resultsPerPage: json['resultsPerPage'] as int,
    );
  }
}

class SearchResult {
  final String kind;
  final String etag;
  final Id id;
  final Snippet snippet;

  SearchResult({
    required this.kind,
    required this.etag,
    required this.id,
    required this.snippet,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      kind: json['kind'] as String,
      etag: json['etag'] as String,
      id: Id.fromJson(json['id'] as Map<String, dynamic>),
      snippet: Snippet.fromJson(json['snippet'] as Map<String, dynamic>),
    );
  }
}

class Id {
  final String kind;
  final String videoId;

  Id({
    required this.kind,
    required this.videoId,
  });

  factory Id.fromJson(Map<String, dynamic> json) {
    return Id(
      kind: json['kind'] as String,
      videoId: json['videoId'] as String,
    );
  }
}

class Snippet {
  final DateTime publishedAt;
  final String channelId;
  final String title;
  final String description;
  final Thumbnails thumbnails;
  final String channelTitle;
  final String liveBroadcastContent;
  final DateTime publishTime;

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

  factory Snippet.fromJson(Map<String, dynamic> json) {
    return Snippet(
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      channelId: json['channelId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnails: Thumbnails.fromJson(json['thumbnails'] as Map<String, dynamic>),
      channelTitle: json['channelTitle'] as String,
      liveBroadcastContent: json['liveBroadcastContent'] as String,
      publishTime: DateTime.parse(json['publishTime'] as String),
    );
  }
}

class Thumbnails {
  final Default thumbnailDefault;
  final Medium? medium;
  final High? high;

  Thumbnails({
    required this.thumbnailDefault,
    this.medium,
    this.high,
  });

  factory Thumbnails.fromJson(Map<String, dynamic> json) {
    return Thumbnails(
      thumbnailDefault: Default.fromJson(json['default'] as Map<String, dynamic>),
      medium: json['medium'] == null
          ? null
          : Medium.fromJson(json['medium'] as Map<String, dynamic>),
      high: json['high'] == null
          ? null
          : High.fromJson(json['high'] as Map<String, dynamic>),
    );
  }
}

class Default {
  final String url;
  final int width;
  final int height;

  Default({
    required this.url,
    required this.width,
    required this.height,
  });

  factory Default.fromJson(Map<String, dynamic> json) {
    return Default(
      url: json['url'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }
}

class Medium {
  final String url;
  final int width;
  final int height;

  Medium({
    required this.url,
    required this.width,
    required this.height,
  });

  factory Medium.fromJson(Map<String, dynamic> json) {
    return Medium(
      url: json['url'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }
}

class High {
  final String url;
  final int width;
  final int height;

  High({
    required this.url,
    required this.width,
    required this.height,
  });

  factory High.fromJson(Map<String, dynamic> json) {
    return High(
      url: json['url'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }
}


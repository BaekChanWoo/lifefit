class SearchResponse {
  final String lastBuildDate;
  final int total;
  final int start;
  final int display;
  final List<ArticleItem> items;

  SearchResponse({
    required this.lastBuildDate,
    required this.total,
    required this.start,
    required this.display,
    required this.items,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List; // JSON 배열을 List로 가져옴
    List<ArticleItem> parsedItems = itemsList.map((i) => ArticleItem.fromJson(i)).toList(); // 각 아이템을 ArticleItem으로 변환

    return SearchResponse(
      lastBuildDate: json['lastBuildDate'] ?? '', // null이면 빈 문자열
      total: json['total'] ?? 0, // null이면 0
      start: json['start'] ?? 0, // null이면 0
      display: json['display'] ?? 0, // null이면 0
      items: parsedItems,
    );
  }
}

class ArticleItem {
  final String title;
  final String originallink;
  final String link;
  final String description;
  final String pubDate;

  ArticleItem({
    required this.title,
    required this.originallink,
    required this.link,
    required this.description,
    required this.pubDate,
  });

  factory ArticleItem.fromJson(Map<String, dynamic> json) {
    return ArticleItem(
      title: json['title'] ?? '',
      originallink: json['originallink'] ?? '',
      link: json['link'] ?? '',
      description: json['description'] ?? '',
      pubDate: json['pubDate'] ?? '',
    );
  }
}

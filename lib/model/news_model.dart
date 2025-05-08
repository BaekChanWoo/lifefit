class NewsArticle {
  final String articleId;
  final String title;
  final String link;
  final List<String>? keywords; // Nullable List
  final List<String>? creator; // Nullable List
  final String description;
  final String? content; // Nullable
  final String pubDate;
  final String pubDateTZ;
  final String? imageUrl; // Nullable
  final String? videoUrl; // Nullable
  final String sourceId;
  final String sourceName;
  final int? sourcePriority; // Nullable
  final String sourceUrl;
  final String? sourceIcon; // Nullable
  final String language;
  final List<String>? country; // Nullable List
  final List<String>? category; // Nullable List
  final String? sentiment; // Nullable
  final String? sentimentStats; // Nullable
  final String? aiTag; // Nullable
  final String? aiRegion; // Nullable
  final String? aiOrg; // Nullable
  final bool? duplicate; // Nullable

  NewsArticle({
    required this.articleId,
    required this.title,
    required this.link,
    this.keywords,
    this.creator,
    required this.description,
    this.content,
    required this.pubDate,
    required this.pubDateTZ,
    this.imageUrl,
    this.videoUrl,
    required this.sourceId,
    required this.sourceName,
    this.sourcePriority,
    required this.sourceUrl,
    this.sourceIcon,
    required this.language,
    this.country,
    this.category,
    this.sentiment,
    this.sentimentStats,
    this.aiTag,
    this.aiRegion,
    this.aiOrg,
    this.duplicate,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      articleId: json['article_id'] ?? '',
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      keywords: json['keywords'] != null ? List<String>.from(json['keywords']) : null,
      creator: json['creator'] != null ? List<String>.from(json['creator']) : null,
      description: json['description'] ?? '',
      content: json['content'],
      pubDate: json['pubDate'] ?? '',
      pubDateTZ: json['pubDateTZ'] ?? '',
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      sourceId: json['source_id'] ?? '',
      sourceName: json['source_name'] ?? '',
      sourcePriority: json['source_priority'],
      sourceUrl: json['source_url'] ?? '',
      sourceIcon: json['source_icon'],
      language: json['language'] ?? '',
      country: json['country'] != null ? List<String>.from(json['country']) : null,
      category: json['category'] != null ? List<String>.from(json['category']) : null,
      sentiment: json['sentiment'],
      sentimentStats: json['sentiment_stats'],
      aiTag: json['ai_tag'],
      aiRegion: json['ai_region'],
      aiOrg: json['ai_org'],
      duplicate: json['duplicate'],
    );
  }
}
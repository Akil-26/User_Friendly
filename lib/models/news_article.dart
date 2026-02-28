class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
    required this.url,
    required this.publishedAt,
    required this.matchedTag,
  });

  final String id;
  final String title;
  final String description;
  final String source;
  final String url;
  final DateTime publishedAt;
  final String matchedTag;
}

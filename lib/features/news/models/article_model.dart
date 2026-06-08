class ArticleModel {
  final String title;
  final String link;
  final String source;
  final String summary;
  final String interest;
  final String? publishedRaw;
  final String publishedDisplay;

  ArticleModel({
    required this.title,
    required this.link,
    required this.source,
    required this.summary,
    required this.interest,
    this.publishedRaw,
    required this.publishedDisplay,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      source: json['source'] ?? 'News',
      summary: json['summary'] ?? '',
      interest: json['interest'] ?? '',
      publishedRaw: json['published_raw'],
      publishedDisplay: json['published_display'] ?? '',
    );
  }
}
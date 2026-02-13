class NewsArticle {
  final String title;
  final String? url;
  final String? imageUrl;
  final String? date;

  NewsArticle({
    required this.title,
    this.url,
    this.imageUrl,
    this.date,
  });
}

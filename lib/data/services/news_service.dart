import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import '../models/news_article.dart';

class NewsService {
  final String _baseUrl = 'https://ami.mr';

  Future<List<NewsArticle>> fetchLatestNews() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final List<NewsArticle> newsList = [];

        // Try to find news items. 
        // Based on analysis, news links often look like /archives/123456
        // and are usually contained in h1, h2, h3, or h4 tags.
        
        // Strategy: Find all anchor tags that link to archives
        final elements = document.getElementsByTagName('a');
        
        for (var element in elements) {
          final href = element.attributes['href'];
          final text = element.text.trim();
          
          if (href != null && href.contains('/archives/') && text.isNotEmpty) {
             // Avoid duplicates and very short texts
             if (newsList.any((n) => n.title == text) || text.length < 10) continue;

             // Try to find an image associated with this news
             // Often images are in the same container or previous sibling
             String? imageUrl;
             // Logic to find image can be complex, for now we might skip or try:
             // finding an img tag inside the same parent container
             
             // Check if it's a "Read More" link (usually short or specific text)
             if (text == 'اقرأ المزيد' || text == 'Read More') continue;

             newsList.add(NewsArticle(
               title: text,
               url: href.startsWith('http') ? href : '$_baseUrl$href',
               imageUrl: imageUrl, // Will need better logic for image
             ));
          }
        }
        
        // If we found too many, maybe limit them or filter better.
        // The homepage might list the same article multiple times (slider, ticker, list).
        return newsList.take(20).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news: $e');
      // Return empty list or rethrow depending on needs. 
      // Returning empty list allows UI to handle it gracefully or show fallback.
      return [];
    }
  }
}

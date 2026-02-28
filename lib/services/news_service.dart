import 'dart:convert';
import 'dart:io';

import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/news_article.dart';
import 'tag_storage_service.dart';

class NewsService {
  NewsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final HtmlUnescape _unescape = HtmlUnescape();

  static const Set<String> _trustedSources = <String>{
    'associated press',
    'ap news',
    'reuters',
    'bbc',
    'npr',
    'cnn',
    'abc news',
    'nbc news',
    'cbs news',
    'the washington post',
    'the wall street journal',
    'the new york times',
    'financial times',
    'bloomberg',
    'al jazeera',
    'the guardian',
    'time',
    'forbes',
    'hindustan times',
    'the hindu',
    'indian express',
    'ndtv',
    'business standard',
    'mint',
  };

  Future<List<NewsArticle>> fetchNewsByTags(
    List<String> tags, {
    int limitPerTag = 12,
  }) async {
    final List<String> normalizedTags = _normalizeTags(tags);
    final List<String> effectiveTags = normalizedTags.isEmpty
        ? List<String>.from(kDefaultNewsTags)
        : normalizedTags;
    final List<NewsArticle> allArticles = <NewsArticle>[];
    final List<Object> failures = <Object>[];

    for (final String tag in effectiveTags) {
      try {
        final Uri uri = Uri.https(
          'news.google.com',
          '/rss/search',
          <String, String>{
            'q': '$tag when:1d',
            'hl': 'en-US',
            'gl': 'US',
            'ceid': 'US:en',
          },
        );
        final http.Response response = await _client.get(
          uri,
          headers: <String, String>{
            'Accept': 'application/rss+xml',
          },
        );

        if (response.statusCode != 200) {
          failures.add(
            'Failed for "$tag" with status ${response.statusCode}',
          );
          continue;
        }

        allArticles.addAll(
          _parseFeed(
            response.body,
            matchedTag: tag,
            limit: limitPerTag,
          ),
        );
      } catch (error) {
        failures.add(error);
      }
    }

    if (allArticles.isEmpty) {
      if (failures.isNotEmpty) {
        throw Exception('Unable to load live news right now.');
      }
      return const <NewsArticle>[];
    }

    final Map<String, NewsArticle> deduped = <String, NewsArticle>{};
    for (final NewsArticle article in allArticles) {
      final NewsArticle? existing = deduped[article.id];
      if (existing == null ||
          article.publishedAt.isAfter(existing.publishedAt)) {
        deduped[article.id] = article;
      }
    }

    final List<NewsArticle> sorted = deduped.values.toList()
      ..sort(
        (NewsArticle a, NewsArticle b) =>
            b.publishedAt.compareTo(a.publishedAt),
      );

    final List<NewsArticle> trusted = sorted
        .where((NewsArticle article) => _isTrustedSource(article.source))
        .toList();

    final List<NewsArticle> selected = trusted.isNotEmpty ? trusted : sorted;
    return selected.take(50).toList(growable: false);
  }

  List<NewsArticle> _parseFeed(
    String xmlBody, {
    required String matchedTag,
    required int limit,
  }) {
    final XmlDocument document = XmlDocument.parse(xmlBody);
    final Iterable<XmlElement> items = document
        .findAllElements('item')
        .take(limit);
    final List<NewsArticle> output = <NewsArticle>[];

    for (final XmlElement item in items) {
      final NewsArticle? article = _parseItem(item, matchedTag);
      if (article != null) {
        output.add(article);
      }
    }

    return output;
  }

  NewsArticle? _parseItem(XmlElement item, String matchedTag) {
    final String rawTitle = _decode(_textForTag(item, 'title'));
    final String link = _textForTag(item, 'link');
    final String source = _extractSource(item, rawTitle);
    final String title = _stripSourceFromTitle(rawTitle, source);

    if (title.isEmpty || link.isEmpty) {
      return null;
    }

    final String description = _cleanDescription(_textForTag(item, 'description'));
    final DateTime publishedAt = _parseDate(_textForTag(item, 'pubDate'));
    final String id = _buildArticleId(title, link);

    return NewsArticle(
      id: id,
      title: title,
      description: description.isEmpty
          ? 'Open this story to read the full details.'
          : description,
      source: source.isEmpty ? 'Unknown source' : source,
      url: link,
      publishedAt: publishedAt,
      matchedTag: matchedTag,
    );
  }

  String _textForTag(XmlElement item, String tag) {
    final Iterable<XmlElement> elements = item.findElements(tag);
    if (elements.isEmpty) {
      return '';
    }
    return elements.first.innerText.trim();
  }

  String _extractSource(XmlElement item, String title) {
    final String explicit = _decode(_textForTag(item, 'source'));
    if (explicit.isNotEmpty) {
      return explicit;
    }

    final int separatorIndex = title.lastIndexOf(' - ');
    if (separatorIndex > 0) {
      return title.substring(separatorIndex + 3).trim();
    }

    return 'Unknown source';
  }

  String _stripSourceFromTitle(String title, String source) {
    final String suffix = ' - $source';
    if (source != 'Unknown source' && title.endsWith(suffix)) {
      return title.substring(0, title.length - suffix.length).trim();
    }
    return title.trim();
  }

  DateTime _parseDate(String rawDate) {
    if (rawDate.isEmpty) {
      return DateTime.now();
    }

    try {
      return HttpDate.parse(rawDate).toLocal();
    } catch (_) {
      try {
        return DateTime.parse(rawDate).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  String _cleanDescription(String value) {
    final String withoutTags = value.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final String decoded = _decode(withoutTags);
    return decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _decode(String value) => _unescape.convert(value);

  String _buildArticleId(String title, String link) {
    final String base = '${title.toLowerCase()}|${link.toLowerCase()}';
    return base64Url.encode(utf8.encode(base)).replaceAll('=', '');
  }

  List<String> _normalizeTags(List<String> tags) {
    final Set<String> seen = <String>{};
    final List<String> output = <String>[];

    for (final String rawTag in tags) {
      final String tag = rawTag.trim().toLowerCase();
      if (tag.isEmpty || seen.contains(tag)) {
        continue;
      }
      seen.add(tag);
      output.add(tag);
    }

    return output;
  }

  bool _isTrustedSource(String source) {
    final String normalized = source
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (normalized.isEmpty) {
      return false;
    }

    for (final String trusted in _trustedSources) {
      if (normalized.contains(trusted) || trusted.contains(normalized)) {
        return true;
      }
    }

    return false;
  }
}

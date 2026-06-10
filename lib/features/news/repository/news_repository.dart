import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../models/article_model.dart';

class NewsRepository {
  final ApiService _apiService;

  NewsRepository(this._apiService);

  // Home page — user interests only
  Future<List<ArticleModel>> getFeed({int limit = 10}) async {
    try {
      final response = await _apiService.dio.get(
        '/news/feed',
        queryParameters: {'limit': limit},
      );
      final articles = response.data['articles'] as List? ?? [];
      return articles.map((a) => ArticleModel.fromJson(a)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw _handleError(e);
    }
  }

  // Explore/Feed page — all built-in + user custom
  Future<List<ArticleModel>> getExploreFeed({int limit = 10}) async {
    try {
      final response = await _apiService.dio.get(
        '/news/explore',
        queryParameters: {'limit': limit},
      );
      final articles = response.data['articles'] as List? ?? [];
      return articles.map((a) => ArticleModel.fromJson(a)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw _handleError(e);
    }
  }

  // Single topic chip tap — both pages
  Future<List<ArticleModel>> getFeedByInterest(
    String interest, {
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/news/feed/$interest',
        queryParameters: {'limit': limit},
      );
      final articles = response.data['articles'] as List? ?? [];
      return articles.map((a) => ArticleModel.fromJson(a)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw _handleError(e);
    }
  }

  // Get topics for explore tabs
  Future<Map<String, List<String>>> getTopics() async {
    try {
      final response = await _apiService.dio.get('/news/topics');
      return {
        'builtin': List<String>.from(response.data['builtin']),
        'custom': List<String>.from(response.data['custom']),
        'all': List<String>.from(response.data['all']),
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data?['detail'] != null) {
      return e.response!.data['detail'].toString();
    }
    switch (e.response?.statusCode) {
      case 401: return 'Please login again';
      case 503: return 'Could not fetch news right now';
      default:  return 'Something went wrong';
    }
  }
}
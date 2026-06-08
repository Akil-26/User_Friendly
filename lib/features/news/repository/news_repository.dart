import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../models/article_model.dart';

class NewsRepository {
  final ApiService _apiService;

  NewsRepository(this._apiService);

  Future<List<ArticleModel>> getFeed({int limit = 10}) async {
    try {
      final response = await _apiService.dio.get(
        '/news/feed',
        queryParameters: {'limit': limit},
      );
      final articles = response.data['articles'] as List;
      return articles.map((a) => ArticleModel.fromJson(a)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ArticleModel>> getFeedByInterest(
  String interest, {
  int limit = 10,
}) async {
  try {
    final response = await _apiService.dio.get(
      '/news/feed/$interest',
      queryParameters: {'limit': limit},
    );

    final data = response.data;
    final articles = data['articles'] as List? ?? [];

    // If backend fuzzy-matched to a different topic, still show articles
    // If suggestions returned (no articles), return empty — UI shows fallback
    return articles.map((a) => ArticleModel.fromJson(a)).toList();
  } on DioException catch (e) {
    // 404 = topic not found at all — return empty instead of crashing
    if (e.response?.statusCode == 404) return [];
    throw _handleError(e);
  }
}

  Future<List<String>> getTopics() async {
    try {
      final response = await _apiService.dio.get('/news/topics');
      return List<String>.from(response.data['topics']);
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
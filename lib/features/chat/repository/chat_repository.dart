import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';

class ChatRepository {
  final ApiService _apiService;

  ChatRepository(this._apiService);

  // Called when user taps YES on dialog
  Future<Map<String, dynamic>> embedArticle({
    required String articleUrl,
    required String articleTitle,
  }) async {
    try {
      final response = await _apiService.dio.post('/chat/embed', data: {
        'article_url': articleUrl,
        'article_title': articleTitle,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Called when user sends a message
  Future<String> askQuestion({
    required String articleUrl,
    required String question,
  }) async {
    try {
      final response = await _apiService.dio.post('/chat/ask', data: {
        'article_url': articleUrl,
        'question': question,
      });
      return response.data['answer'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data?['detail'] != null) {
      return e.response!.data['detail'].toString();
    }
    switch (e.response?.statusCode) {
      case 404: return 'Article not embedded yet';
      case 401: return 'Please login again';
      case 503: return 'AI service unavailable';
      default:  return 'Something went wrong';
    }
  }
}
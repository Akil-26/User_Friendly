import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<String> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final token = response.data['access_token'];
      await _apiService.saveToken(token);
      return token;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> register({
    required String name,
    required String email,
    required String password,
    List<String> interests = const [],
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'interests': interests,
        },
      );
      final token = response.data['access_token'];
      await _apiService.saveToken(token);
      return token;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _apiService.dio.get('/auth/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> updateInterests(List<String> interests) async {
    try {
      final response = await _apiService.dio.put(
        '/auth/me/interests',
        data: {'interests': interests},
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _apiService.deleteToken();
  }

  Future<bool> isLoggedIn() async {
    return await _apiService.hasToken();
  }

  String _handleError(DioException e) {
    if (e.response?.data?['detail'] != null) {
      return e.response!.data['detail'].toString();
    }
    switch (e.response?.statusCode) {
      case 401:
        return 'Invalid email or password';
      case 400:
        return 'Email already registered';
      case 422:
        return 'Please check your input';
      default:
        return 'Something went wrong. Try again.';
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiService.dio.put(
        '/auth/me/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      await _apiService.dio.delete('/auth/me', data: {'password': password});
      await _apiService.deleteToken();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

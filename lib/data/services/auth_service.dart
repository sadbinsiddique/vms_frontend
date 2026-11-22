import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/hive_service.dart';
import '../../models/user_model.dart';

/// Authentication service interacting with backend `/auth` endpoints.
class AuthService {
  final Dio _dio;

  AuthService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  UserModel? get currentUser => HiveService.instance.getUser();

  bool get isAuthenticated => HiveService.instance.isAuthenticated;

  /// Log in with email and password, persisting the received JWT token.
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data;
      Map<String, dynamic> responseData = {};

      if (data is Map<String, dynamic>) {
        if (data['data'] is Map<String, dynamic>) {
          responseData = data['data'] as Map<String, dynamic>;
        } else {
          responseData = data;
        }
      }

      final token = responseData['token']?.toString() ??
          responseData['accessToken']?.toString() ??
          '';

      final userMap = responseData['user'] is Map<String, dynamic>
          ? responseData['user'] as Map<String, dynamic>
          : responseData;

      final user = UserModel.fromJson(userMap);

      if (token.isNotEmpty) {
        await HiveService.instance.setAuthToken(token);
      }
      await HiveService.instance.setUser(user);

      return user;
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  /// Log out from backend session and clear local tokens.
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // Ignore network errors during logout
    } finally {
      await HiveService.instance.clearAll();
    }
  }
}

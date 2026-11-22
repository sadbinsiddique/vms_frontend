import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/hive_service.dart';

/// Global HTTP client configured for backend REST communication with JWT interceptors.
class ApiClient {
  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._();

  late final Dio dio;

  ApiClient._({String? baseUrl}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          try {
            final token = HiveService.instance.getAuthToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {}
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          if (error.response?.statusCode == 401) {
            try {
              HiveService.instance.removeAuthToken();
              HiveService.instance.removeUser();
            } catch (_) {}
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Extracts readable error messages from backend response payloads or network errors.
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response != null && error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map) {
          if (data['error'] != null) return data['error'].toString();
          if (data['message'] != null) return data['message'].toString();
          if (data['errors'] != null) {
            final errors = data['errors'];
            if (errors is Map) {
              return errors.values.map((v) => v.toString()).join('\n');
            }
            return errors.toString();
          }
        } else if (data is String && data.isNotEmpty) {
          return data;
        }
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please verify that the backend server is reachable.';
        case DioExceptionType.connectionError:
          return 'Unable to connect to backend server at ${AppConstants.apiBaseUrl}. Please ensure your backend is running.';
        case DioExceptionType.badResponse:
          return 'Server error (HTTP ${error.response?.statusCode ?? 'unknown'}).';
        default:
          return error.message ?? 'An unexpected network error occurred.';
      }
    }
    return error.toString();
  }
}

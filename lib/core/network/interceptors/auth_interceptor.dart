import 'package:dio/dio.dart';
import '../../storage/local_storage.dart';

/// Interceptor that attaches the authentication token to requests.
class AuthInterceptor extends Interceptor {
  final LocalStorage _localStorage;

  AuthInterceptor({required LocalStorage localStorage})
      : _localStorage = localStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _localStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired — clear stored tokens
      _localStorage.clearTokens();
    }
    super.onError(err, handler);
  }
}

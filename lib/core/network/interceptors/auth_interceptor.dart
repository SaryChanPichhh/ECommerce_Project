import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../storage/local_storage.dart';
import '../user_session.dart';

/// Interceptor that attaches the Bearer authentication token from [UserSession]
/// to requests, while bypassing public endpoints that do not require authentication
/// according to frontend_integration_guide.md.
class AuthInterceptor extends Interceptor {
  final LocalStorage _localStorage;

  AuthInterceptor({required LocalStorage localStorage})
      : _localStorage = localStorage;

  /// Routes that strictly do NOT need or accept authorization tokens.
  static final List<String> _noTokenRoutes = [
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.forgotPassword,
    ApiConstants.resetPassword,
    '/legacy-auth/login',
  ];

  /// Purely public catalog endpoints that do not need tokens.
  static final List<String> _publicCatalogRoutes = [
    '/public/categories/',
    '/public/tags/',
    '/tags/',
    '/public/legal-documents/',
    '/legal-documents/',
    '/images/',
    '/variants/',
    '/variant-options/',
    '/public/reviews/',
  ];

  /// Check whether the route requires no token according to the integration guide.
  bool _isNoTokenRequired(RequestOptions options) {
    // 1. Explicit request flag (e.g. Options(extra: {'noToken': true}))
    if (options.extra['noToken'] == true ||
        options.extra['requiresToken'] == false) {
      return true;
    }

    final path = options.path;

    // 2. Strict public auth entrypoints (login, register, forgot-pw, reset-pw)
    for (final route in _noTokenRoutes) {
      if (path == route ||
          path.endsWith(route) ||
          path.contains(route.replaceAll('/', ''))) {
        return true;
      }
    }

    // 3. Pure public catalog/legal routes that have no token requirements
    // (Only if user has no token or if route specifically is purely public)
    for (final route in _publicCatalogRoutes) {
      if (path.contains(route)) {
        return true;
      }
    }

    return false;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Check if the route is a public no-token route
    if (_isNoTokenRequired(options)) {
      // Remove any lingering Authorization header if present
      options.headers.remove('Authorization');
    } else {
      // For customer protected routes (and optional auth routes),
      // retrieve access token from the UserSession singleton (falling back to storage)
      final token = UserSession.instance.accessToken ??
          _localStorage.getAccessToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Invalidate in-memory singleton session and persisted storage
      UserSession.instance.clear();
      _localStorage.clearAuthData();
    }
    super.onError(err, handler);
  }
}

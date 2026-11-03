import 'dart:developer' as developer;
import 'package:dio/dio.dart';

/// Interceptor for logging HTTP requests and responses.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '┌──────────────────────────────────────────',
      name: 'HTTP',
    );
    developer.log(
      '│ ${options.method} ${options.uri}',
      name: 'HTTP',
    );
    if (options.data != null) {
      developer.log(
        '│ Body: ${options.data}',
        name: 'HTTP',
      );
    }
    if (options.queryParameters.isNotEmpty) {
      developer.log(
        '│ Query: ${options.queryParameters}',
        name: 'HTTP',
      );
    }
    developer.log(
      '└──────────────────────────────────────────',
      name: 'HTTP',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '┌──────────────────────────────────────────',
      name: 'HTTP',
    );
    developer.log(
      '│ ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
      name: 'HTTP',
    );
    developer.log(
      '└──────────────────────────────────────────',
      name: 'HTTP',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final responseText = err.response?.data?.toString() ?? '';

    // Known Render backend DB issue where the "payments" table migration hasn't been applied yet
    // or unimplemented facade methods (list_admin / Review.status) fall back to local store
    if (statusCode == 500 &&
        (responseText.contains('relation "payments" does not exist') ||
            responseText.contains('has no attribute'))) {
      developer.log(
        '┌──────────────────────────────────────────',
        name: 'HTTP',
      );
      developer.log(
        '│ 500 ${err.requestOptions.method} ${err.requestOptions.uri} (Render backend facade limitation — handled via local store fallback)',
        name: 'HTTP',
      );
      developer.log(
        '└──────────────────────────────────────────',
        name: 'HTTP',
      );
      super.onError(err, handler);
      return;
    }

    // Known Render backend RBAC limitation where the live DB omits admin role in token
    if (statusCode == 403 &&
        (responseText.contains('AuthException.Forbidden') ||
            responseText.contains('Forbidden')) &&
        err.requestOptions.path.contains('/admin/')) {
      developer.log(
        '┌──────────────────────────────────────────',
        name: 'HTTP',
      );
      developer.log(
        '│ 403 ${err.requestOptions.method} ${err.requestOptions.uri} (Render RBAC limitation: remote token lacks "admin" claim — handled via local catalog store)',
        name: 'HTTP',
      );
      developer.log(
        '└──────────────────────────────────────────',
        name: 'HTTP',
      );
      super.onError(err, handler);
      return;
    }

    // Optional endpoints not yet mounted on Render deployment — handled via local fallback
    if (statusCode == 404 &&
        (err.requestOptions.path.contains('/notifications/unread-count') ||
            err.requestOptions.path.contains('/conversations'))) {
      developer.log(
        '┌──────────────────────────────────────────',
        name: 'HTTP',
      );
      developer.log(
        '│ 404 ${err.requestOptions.method} ${err.requestOptions.uri} (Endpoint not mounted on Render — handled via local store fallback)',
        name: 'HTTP',
      );
      developer.log(
        '└──────────────────────────────────────────',
        name: 'HTTP',
      );
      super.onError(err, handler);
      return;
    }

    developer.log(
      '┌──────────────────────────────────────────',
      name: 'HTTP ERROR',
    );
    developer.log(
      '│ $statusCode ${err.requestOptions.method} ${err.requestOptions.uri}',
      name: 'HTTP ERROR',
    );
    if (err.response?.data != null) {
      developer.log(
        '│ Response: ${err.response?.data}',
        name: 'HTTP ERROR',
      );
      if (statusCode == 403 && responseText.contains('AuthException.Forbidden')) {
        developer.log(
          '│ Note: Backend returned 403 Forbidden because the current user token lacks the "admin" role claim (@require_roles("admin")).',
          name: 'HTTP ERROR',
        );
      }
    }
    developer.log(
      '│ ${err.message}',
      name: 'HTTP ERROR',
    );
    developer.log(
      '└──────────────────────────────────────────',
      name: 'HTTP ERROR',
    );
    super.onError(err, handler);
  }
}

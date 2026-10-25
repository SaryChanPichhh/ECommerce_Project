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
    if (statusCode == 500 &&
        responseText.contains('relation "payments" does not exist')) {
      developer.log(
        '┌──────────────────────────────────────────',
        name: 'HTTP',
      );
      developer.log(
        '│ 500 ${err.requestOptions.method} ${err.requestOptions.uri} (Backend DB missing "payments" table — handled via local order fallback)',
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

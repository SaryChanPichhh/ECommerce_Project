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
    developer.log(
      '┌──────────────────────────────────────────',
      name: 'HTTP ERROR',
    );
    developer.log(
      '│ ${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.uri}',
      name: 'HTTP ERROR',
    );
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

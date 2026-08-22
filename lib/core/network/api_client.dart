import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Centralized API client using Dio.
/// All HTTP requests should go through this single client.
class ApiClient {
  late final Dio _dio;

  ApiClient({Dio? dio}) {
    _dio = dio ?? Dio();
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  /// Add interceptors after construction (to allow DI of storage).
  void addInterceptors(List<Interceptor> interceptors) {
    _dio.interceptors.addAll(interceptors);
  }

  /// GET request.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// POST request.
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// PUT request.
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// PATCH request.
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// DELETE request.
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Convert DioException into application-specific exceptions.
  AppException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(message: 'Connection timed out');

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _handleResponseError(e.response);

      case DioExceptionType.cancel:
        return const AppException(message: 'Request was cancelled');

      default:
        return AppException(
          message: e.message ?? 'An unexpected error occurred',
        );
    }
  }

  /// Map HTTP status codes to specific exceptions.
  AppException _handleResponseError(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;
    final message = data is Map<String, dynamic>
        ? (data['message'] as String?) ?? 'Server error'
        : 'Server error';

    switch (statusCode) {
      case 400:
        return ServerException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return const UnauthorizedException(
          message: 'Access forbidden',
        );
      case 404:
        return NotFoundException(message: message);
      case 422:
        final errors = data is Map<String, dynamic> && data['errors'] != null
            ? (data['errors'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(
                  key,
                  (value as List).map((e) => e.toString()).toList(),
                ),
              )
            : null;
        return ValidationException(
          message: message,
          errors: errors,
        );
      case 500:
        return ServerException(
          message: message,
          statusCode: statusCode,
        );
      default:
        return ServerException(
          message: message,
          statusCode: statusCode,
        );
    }
  }
}

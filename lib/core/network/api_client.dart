import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

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

    String message = 'Server error occurred';
    Map<String, List<String>>? validationErrors;

    if (data is Map<String, dynamic>) {
      // Check for standard error envelope: errors: [...]
      if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        final errorList = data['errors'] as List;
        final messages = <String>[];
        final fieldErrors = <String, List<String>>{};

        for (final item in errorList) {
          if (item is Map) {
            final msg = item['message']?.toString() ?? item['code']?.toString() ?? '';
            final field = item['field']?.toString();
            if (msg.isNotEmpty) {
              messages.add(msg);
              if (field != null && field.isNotEmpty) {
                fieldErrors.putIfAbsent(field, () => []).add(msg);
              }
            }
          } else if (item is String && item.isNotEmpty) {
            messages.add(item);
          }
        }
        if (messages.isNotEmpty) {
          message = messages.join('. ');
        }
        if (fieldErrors.isNotEmpty) {
          validationErrors = fieldErrors;
        }
      } else if (data['errors'] is Map) {
        validationErrors = (data['errors'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key,
            value is List
                ? value.map((e) => e.toString()).toList()
                : [value.toString()],
          ),
        );
        message = validationErrors.values.expand((e) => e).join('. ');
      } else if (data['error'] is Map<String, dynamic>) {
        final errMap = data['error'] as Map<String, dynamic>;
        if (errMap['bodyRequestError'] is Map) {
          final bodyErr = errMap['bodyRequestError'] as Map;
          validationErrors = bodyErr.map(
            (key, value) => MapEntry(
              key.toString(),
              value is List
                  ? value.map((e) => e.toString()).toList()
                  : [value.toString()],
            ),
          );
          message = validationErrors.entries
              .map((e) => '${e.key}: ${e.value.join(", ")}')
              .join('. ');
        } else if (errMap['message'] is String &&
            (errMap['message'] as String).isNotEmpty) {
          message = errMap['message'] as String;
        } else if (data['message'] is String &&
            (data['message'] as String).isNotEmpty) {
          message = data['message'] as String;
        }
      } else if (data['message'] is String && (data['message'] as String).isNotEmpty) {
        message = data['message'] as String;
      } else if (data['detail'] is String && (data['detail'] as String).isNotEmpty) {
        message = data['detail'] as String;
      } else if (data['error'] is String && (data['error'] as String).isNotEmpty) {
        message = data['error'] as String;
      }
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        if (validationErrors != null && validationErrors.isNotEmpty) {
          return ValidationException(
            message: message,
            errors: validationErrors,
          );
        }
        return ServerException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return UnauthorizedException(
          message: message.isNotEmpty ? message : 'Access forbidden',
        );
      case 404:
        return NotFoundException(message: message);
      case 409:
        return ServerException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
      case 422:
        return ValidationException(
          message: message,
          errors: validationErrors,
        );
      case 500:
      default:
        return ServerException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
    }
  }
}

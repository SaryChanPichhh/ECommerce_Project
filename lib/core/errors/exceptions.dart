/// Base exception for the application.
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const AppException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'AppException: $message (statusCode: $statusCode)';
}

/// Exception thrown when there is a network-related error.
class NetworkException extends AppException {
  const NetworkException({String message = 'No internet connection'})
      : super(message: message);
}

/// Exception thrown when the server returns an error.
class ServerException extends AppException {
  const ServerException({
    String message = 'Server error occurred',
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

/// Exception thrown when the user is unauthorized (401).
class UnauthorizedException extends AppException {
  const UnauthorizedException({String message = 'Unauthorized access'})
      : super(message: message, statusCode: 401);
}

/// Exception thrown when a resource is not found (404).
class NotFoundException extends AppException {
  const NotFoundException({String message = 'Resource not found'})
      : super(message: message, statusCode: 404);
}

/// Exception thrown when validation fails.
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    String message = 'Validation failed',
    this.errors,
  }) : super(message: message, statusCode: 422);
}

/// Exception thrown when data caching fails.
class CacheException extends AppException {
  const CacheException({String message = 'Cache error occurred'})
      : super(message: message);
}

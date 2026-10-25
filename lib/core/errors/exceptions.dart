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
  const NetworkException({super.message = 'No internet connection'});
}

/// Exception thrown when the server returns an error.
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server error occurred',
    super.statusCode,
    super.data,
  });
}

/// Exception thrown when the user is unauthorized (401).
class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Unauthorized access'})
      : super(statusCode: 401);
}

/// Exception thrown when a resource is not found (404).
class NotFoundException extends AppException {
  const NotFoundException({super.message = 'Resource not found'})
      : super(statusCode: 404);
}

/// Exception thrown when validation fails.
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    super.message = 'Validation failed',
    this.errors,
  }) : super(statusCode: 422);
}

/// Exception thrown when data caching fails.
class CacheException extends AppException {
  const CacheException({super.message = 'Cache error occurred'});
}

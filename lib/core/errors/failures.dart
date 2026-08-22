/// Base failure class for domain-level error handling.
/// The UI layer should only interact with Failure subclasses.
abstract class Failure {
  final String message;

  const Failure({required this.message});

  @override
  String toString() => '$runtimeType: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Failure due to network issues.
class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'No internet connection'})
      : super(message: message);
}

/// Failure due to server errors.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    String message = 'Server error occurred',
    this.statusCode,
  }) : super(message: message);
}

/// Failure due to unauthorized access.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({String message = 'Unauthorized access'})
      : super(message: message);
}

/// Failure due to resource not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({String message = 'Resource not found'})
      : super(message: message);
}

/// Failure due to validation errors.
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    String message = 'Validation failed',
    this.errors,
  }) : super(message: message);
}

/// Failure due to unknown/unexpected errors.
class UnknownFailure extends Failure {
  const UnknownFailure({String message = 'An unexpected error occurred'})
      : super(message: message);
}

/// Failure due to cache errors.
class CacheFailure extends Failure {
  const CacheFailure({String message = 'Cache error occurred'})
      : super(message: message);
}

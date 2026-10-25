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
  const NetworkFailure({super.message = 'No internet connection'});
}

/// Failure due to server errors.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    super.message = 'Server error occurred',
    this.statusCode,
  });
}

/// Failure due to unauthorized access.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Unauthorized access'});
}

/// Failure due to resource not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found'});
}

/// Failure due to validation errors.
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    super.message = 'Validation failed',
    this.errors,
  });
}

/// Failure due to unknown/unexpected errors.
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred'});
}

/// Failure due to cache errors.
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred'});
}

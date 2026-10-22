sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;
  const ValidationException(super.message, this.fieldErrors);
}

class DomainException extends AppException {
  final int statusCode;
  const DomainException(super.message, this.statusCode);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class ServerException extends AppException {
  const ServerException(
      [super.message = 'Server error. Please try again later.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(
      [super.message = 'Session expired. Please log in again.']);
}

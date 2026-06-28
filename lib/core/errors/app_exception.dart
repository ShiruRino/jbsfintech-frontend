class AppException implements Exception {
  const AppException(this.message, {this.code, this.fieldErrors = const {}});

  final String message;
  final int? code;
  final Map<String, List<String>> fieldErrors;

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message) : super(code: 401);
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.fieldErrors})
    : super(code: 422);
}

class ForbiddenException extends AppException {
  const ForbiddenException(super.message) : super(code: 403);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message) : super(code: 404);
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

class UnknownException extends AppException {
  const UnknownException(super.message, {super.code});
}

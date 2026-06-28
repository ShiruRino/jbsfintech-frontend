import '../errors/app_exception.dart';
import '../utils/json_parsers.dart';

class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.status,
    required this.message,
    required this.data,
    this.errors = const {},
  });

  final String status;
  final String message;
  final T data;
  final Map<String, List<String>> errors;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) parser,
  ) {
    final rawErrors = json['errors'];
    return ApiEnvelope<T>(
      status: json['status']?.toString() ?? 'unknown',
      message: json['message']?.toString() ?? '',
      data: parser(json['data']),
      errors: JsonParsers.mapOfStringList(rawErrors),
    );
  }
}

AppException extractApiException(Map<String, dynamic> json, {int? code}) {
  final message = json['message']?.toString() ?? 'Terjadi kesalahan.';
  final errors = JsonParsers.mapOfStringList(json['errors']);

  switch (code) {
    case 401:
      return UnauthorizedException(message);
    case 403:
      return ForbiddenException(message);
    case 404:
      return NotFoundException(message);
    case 422:
      return ValidationException(message, fieldErrors: errors);
    default:
      if (code != null && code >= 500) {
        return ServerException(message, code: code);
      }
      return UnknownException(message, code: code);
  }
}

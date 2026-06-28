import '../errors/app_exception.dart';

sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;
  T? get dataOrNull =>
      this is ApiSuccess<T> ? (this as ApiSuccess<T>).data : null;
  AppException? get errorOrNull =>
      this is ApiFailure<T> ? (this as ApiFailure<T>).exception : null;

  static Future<ApiResult<T>> guard<T>(Future<T> Function() action) async {
    try {
      return ApiSuccess<T>(await action());
    } on AppException catch (error) {
      return ApiFailure<T>(error);
    } catch (error) {
      return ApiFailure<T>(UnknownException(error.toString()));
    }
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.exception);

  final AppException exception;
}

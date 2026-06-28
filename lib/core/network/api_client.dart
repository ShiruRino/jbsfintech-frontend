import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../storage/token_storage.dart';
import '../utils/json_parsers.dart';
import 'api_response.dart';

class ApiClient {
  ApiClient({
    required SecureTokenStorage tokenStorage,
    required Future<void> Function() onUnauthorized,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: AppConfig.apiBaseUrl,
           connectTimeout: const Duration(seconds: 20),
           receiveTimeout: const Duration(seconds: 20),
           sendTimeout: const Duration(seconds: 20),
           headers: const {'Accept': 'application/json'},
         ),
       ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final authRequired = options.extra['authRequired'] != false;
          if (authRequired) {
            final token = await tokenStorage.readToken();
            if (token != null && token.isNotEmpty) {
              options.headers[AppConfig.authHeaderName] =
                  AppConfig.formatAuthHeader(token);
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await onUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;

  Future<ApiEnvelope<dynamic>> get(
    String path, {
    bool authRequired = true,
  }) async {
    return _send(
      () => _dio.get<dynamic>(
        path,
        options: Options(extra: {'authRequired': authRequired}),
      ),
    );
  }

  Future<ApiEnvelope<dynamic>> post(
    String path, {
    Object? data,
    bool authRequired = true,
  }) async {
    return _send(
      () => _dio.post<dynamic>(
        path,
        data: data,
        options: Options(extra: {'authRequired': authRequired}),
      ),
    );
  }

  Future<ApiEnvelope<dynamic>> put(
    String path, {
    Object? data,
    bool authRequired = true,
  }) async {
    return _send(
      () => _dio.put<dynamic>(
        path,
        data: data,
        options: Options(extra: {'authRequired': authRequired}),
      ),
    );
  }

  Future<ApiEnvelope<dynamic>> delete(
    String path, {
    bool authRequired = true,
  }) async {
    return _send(
      () => _dio.delete<dynamic>(
        path,
        options: Options(extra: {'authRequired': authRequired}),
      ),
    );
  }

  Future<ApiEnvelope<dynamic>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final json = JsonParsers.asMap(response.data);
      return ApiEnvelope<dynamic>.fromJson(json, (data) => data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on AppException {
      rethrow;
    } catch (error) {
      throw UnknownException(error.toString());
    }
  }

  AppException _mapDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException('Koneksi gagal. Periksa internet Anda.');
    }

    final response = error.response;
    final json = JsonParsers.asMap(response?.data);
    if (json.isNotEmpty) {
      return extractApiException(json, code: response?.statusCode);
    }

    if (response?.statusCode != null) {
      return ServerException(
        'Permintaan gagal dengan kode ${response!.statusCode}.',
        code: response.statusCode,
      );
    }

    return const UnknownException('Terjadi kesalahan yang tidak dikenali.');
  }
}

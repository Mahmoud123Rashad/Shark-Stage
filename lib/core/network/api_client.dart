import 'package:dio/dio.dart';

import '../config/environment.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'network_exceptions.dart';

/// Thin wrapper around Dio to standardise SharkStage API requests.
final class ApiClient {
  ApiClient({
    Dio? dio,
    AuthInterceptor? authInterceptor,
    LoggingInterceptor? loggingInterceptor,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: EnvironmentConfig.apiBaseUrl,
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 20),
               responseType: ResponseType.json,
               contentType: Headers.jsonContentType,
               headers: <String, dynamic>{'Accept': 'application/json'},
             ),
           ) {
    if (authInterceptor != null &&
        !_dio.interceptors.contains(authInterceptor)) {
      _dio.interceptors.add(authInterceptor);
    }

    if (loggingInterceptor != null &&
        !_dio.interceptors.contains(loggingInterceptor)) {
      _dio.interceptors.add(loggingInterceptor);
    }

    // Ensure all requests include credentials for cookie-based flows.
    _dio.options = _dio.options.copyWith(
      extra: <String, dynamic>{..._dio.options.extra, 'withCredentials': true},
    );
  }

  final Dio _dio;

  Dio get raw => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _guardRequest(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _guardRequest(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _guardRequest(
      () => _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _guardRequest(
      () => _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _guardRequest(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> _guardRequest<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  NetworkException _mapException(DioException error) {
    if (error.type == DioExceptionType.unknown ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkUnavailableException(error.message ?? 'Network error');
    }

    final int statusCode = error.response?.statusCode ?? -1;
    final dynamic data = error.response?.data;
    final String message = switch (data) {
      Map<String, dynamic> map when map['message'] is String =>
        map['message'] as String,
      Map<String, dynamic> map when map['error'] is String =>
        map['error'] as String,
      String str => str,
      _ => 'Unexpected server error',
    };

    return NetworkResponseException(statusCode: statusCode, message: message);
  }
}

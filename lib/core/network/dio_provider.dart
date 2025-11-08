import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/environment.dart';
import '../storage/token_storage_provider.dart';
import 'api_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

final Provider<LoggingInterceptor> loggingInterceptorProvider =
    Provider<LoggingInterceptor>((_) => LoggingInterceptor());

final Provider<AuthInterceptor> authInterceptorProvider =
    Provider<AuthInterceptor>(
      (Ref ref) => AuthInterceptor(ref.watch(tokenStorageProvider)),
    );

final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  final AuthInterceptor authInterceptor = ref.watch(authInterceptorProvider);
  final LoggingInterceptor loggingInterceptor = ref.watch(
    loggingInterceptorProvider,
  );

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: EnvironmentConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
      headers: <String, dynamic>{'Accept': 'application/json'},
    ),
  )..interceptors.addAll(<Interceptor>[authInterceptor, loggingInterceptor]);

  dio.options.extra = <String, dynamic>{
    ...dio.options.extra,
    'withCredentials': true,
  };

  return dio;
});

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>(
  (Ref ref) => ApiClient(
    dio: ref.watch(dioProvider),
    authInterceptor: ref.watch(authInterceptorProvider),
    loggingInterceptor: ref.watch(loggingInterceptorProvider),
  ),
);

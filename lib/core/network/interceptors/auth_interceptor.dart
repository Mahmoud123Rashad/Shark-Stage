import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';

/// Injects the bearer token into outgoing requests when available.
final class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? token = await _tokenStorage.read();
    if (token != null && token.isNotEmpty) {
      options.headers.putIfAbsent('Authorization', () => 'Bearer $token');
    }
    super.onRequest(options, handler);
  }
}

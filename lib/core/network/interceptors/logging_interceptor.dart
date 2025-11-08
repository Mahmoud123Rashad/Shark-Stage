import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Lightweight logging interceptor powered by the `logger` package.
final class LoggingInterceptor extends Interceptor {
  LoggingInterceptor([Logger? logger])
    : _logger =
          logger ??
          Logger(
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 5,
              lineLength: 90,
              colors: true,
              printEmojis: true,
            ),
          );

  final Logger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i(
      '➡️  ${options.method} ${options.uri}\nHeaders: ${options.headers}\nData: ${options.data}',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i(
      '✅ ${response.statusCode} ${response.requestOptions.uri}\nData: ${response.data}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '❌ ${err.response?.statusCode ?? ''} ${err.requestOptions.uri}\nMessage: ${err.message}\nData: ${err.response?.data}',
      error: err,
      stackTrace: err.stackTrace,
    );
    super.onError(err, handler);
  }
}

/// Exceptions that standardise API error handling.
sealed class NetworkException implements Exception {
  const NetworkException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Represents connectivity issues or timeouts.
final class NetworkUnavailableException extends NetworkException {
  // ignore: use_super_parameters
  const NetworkUnavailableException([String message = 'Network request failed'])
    : super(message);
}

/// Server responded with an error status code.
final class NetworkResponseException extends NetworkException {
  const NetworkResponseException({
    required this.statusCode,
    required String message,
  }) : super(message);

  final int statusCode;
}

/// Raised when serialisation fails.
final class NetworkParsingException extends NetworkException {
  // ignore: use_super_parameters
  const NetworkParsingException([String message = 'Failed to parse response'])
    : super(message);
}

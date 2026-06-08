class InvalidCodeException implements Exception {
  const InvalidCodeException();
}

class LockedOutException implements Exception {
  const LockedOutException(this.retryAfter);
  final Duration retryAfter;
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'network_error']);
  final String message;
}
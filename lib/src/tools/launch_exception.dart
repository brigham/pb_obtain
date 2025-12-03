class LaunchException implements Exception {
  final String message;

  LaunchException(this.message);

  @override
  String toString() => 'LaunchException: $message';
}

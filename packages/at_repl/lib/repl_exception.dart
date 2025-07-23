


class REPLException implements Exception {
  final String message;
  final Exception? cause;

  const REPLException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'REPLException: $message\nCaused by: $cause';
    }
    return 'REPLException: $message';
  }
}
class ValidateException {
  static String _prefix = "";

  static void usingPrefix(String prefix, void Function() validator) {
    String oldPrefix = _prefix;
    try {
      _prefix = prefix;
      validator();
    } finally {
      _prefix = oldPrefix;
    }
  }

  final String field;
  final String message;

  ValidateException(String field, this.message) : field = "$_prefix$field";

  @override
  String toString() {
    return "$field: $message";
  }
}

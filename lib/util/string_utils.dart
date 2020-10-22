class StringUtils {
  static String trimTrailing(String pattern, String from) {
    int i = from.length;
    while (from.startsWith(pattern, i - pattern.length)) i -= pattern.length;
    return from.substring(0, i);
  }

  static String trimLeading(String pattern, String from) {
    int i = 0;
    while (from.startsWith(pattern, i)) i += pattern.length;
    return from.substring(i);
  }
}

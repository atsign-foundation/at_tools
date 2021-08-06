class AtRegExp {
  /// RegExp to match the @-sign in a string.
  static RegExp atsign = RegExp(r'@');

  /// RegExp for the special characters.
  /// Skips `a-zA-Z0-9_@`.
  static RegExp specialChar =
      RegExp(r"[\!\*\'`\(\)\;\:\&\=\+\$\,\/\?\#\[\]\{\}\\]");

  /// RegExp for the TAB, WHITESPACE, LINEFEED and NEWLINE unicode characters.
  /// Ref [Wikipedia](https://en.wikipedia.org/wiki/Whitespace_character).
  /// Regular Expression for all kind of whitespace characters with unicodes.
  static RegExp whiteSpaceChar = RegExp(
      r'[\u0009\u000B\u000C\u0020\u00A0\u1680\u180E\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u2028\u2029\u202F\u205F\u3000\uFEFF]');
  // static RegExp whiteSpaceChar = RegExp(
  //     r'[\u0020\u0009\u000A\u000B\u000C\u000D\u0085\u00A0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u2028\u2029\u202F\u205F\u3000]');

  /// ASCII control Characters are not allowed in @signs.
  /// ASCII control Characters RegExp with unicode.
  static RegExp asciicontrolChar = RegExp(r'[\u0000-\u001F\u007F]');

  /// Control Characters are not allowed in @signs.
  /// Control Characters RegExp with unicode.
  static RegExp controlChar =
      RegExp(r'[\u2400-\u241F\u2400\u2421\u2424\u2425]');
}

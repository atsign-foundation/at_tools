import 'dart:collection';

class VerbUtil {
  static const String NEW_LINE_REPLACE_PATTERN = '~NL~';
  static Iterable<RegExpMatch> _getMatches(RegExp regex, String command) {
    Iterable<RegExpMatch> matches = regex.allMatches(command);
    return matches;
  }

  static HashMap<String, String?> _processMatches(
      Iterable<RegExpMatch> matches) {
    HashMap<String, String?> paramsMap = HashMap<String, String?>();
    for(RegExpMatch f in matches) {
      for (String name in f.groupNames) {
        paramsMap.putIfAbsent(name, () => f.namedGroup(name));
      }
    }
    return paramsMap;
  }

  static HashMap<String, String?>? getVerbParam(String regex, String command) {
    RegExp regExp = RegExp(regex);
    Iterable<RegExpMatch> regexMatches = _getMatches(regExp, command);
    if (regexMatches.isEmpty) {
      return null;
    }
    HashMap<String, String?> verbParams = _processMatches(regexMatches);
    return verbParams;
  }

  static String? formatAtSign(String? atSign) {
    if (atSign != null && !atSign.startsWith('@')) {
      atSign = '@$atSign';
    }
    return atSign;
  }

  static String replaceNewline(String value) {
    return value.replaceAll('\n', NEW_LINE_REPLACE_PATTERN);
  }

  static String getFormattedValue(String value) {
    return value.replaceAll(NEW_LINE_REPLACE_PATTERN, '\n');
  }
}

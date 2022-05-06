import 'dart:collection';

import 'package:at_commons/src/keystore/key_type.dart';

class Regexes {
  static const _charsInNamespace = r'([\w])+';
  static const _charsInAtSign = r'[\w\-_]';
  static const _charsInEntity = r'''[\w\.\-_'*"]''';
  static const _allowedEmoji =
      r'''((\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]))''';

  // Ideally these should be mutually exclusive, and they are. Will write tests for that.
  static const publicKey =
      '''(?<visibility>(public:){1})((@(?<sharedWith>($_charsInAtSign|$_allowedEmoji){1,55}):))?(?<entity>($_charsInEntity|$_allowedEmoji)+)\\.(?<namespace>$_charsInNamespace)@(?<owner>($_charsInAtSign|$_allowedEmoji){1,55})''';
  static const privateKey =
      '''(?<visibility>(private:){1})((@(?<sharedWith>($_charsInAtSign|$_allowedEmoji){1,55}):))?(?<entity>($_charsInEntity|$_allowedEmoji)+)\\.(?<namespace>$_charsInNamespace)@(?<owner>($_charsInAtSign|$_allowedEmoji){1,55})''';
  static const selfKey =
      '''((@(?<sharedWith>($_charsInAtSign|$_allowedEmoji){1,55}):))?(_*(?<entity>($_charsInEntity|$_allowedEmoji)+))\\.(?<namespace>$_charsInNamespace)@(?<owner>($_charsInAtSign|$_allowedEmoji){1,55})''';
  static const sharedKey =
      '''((@(?<sharedWith>($_charsInAtSign|$_allowedEmoji){1,55}):))(_*(?<entity>($_charsInEntity|$_allowedEmoji)+))\\.(?<namespace>$_charsInNamespace)@(?<owner>($_charsInAtSign|$_allowedEmoji){1,55})''';
  static const cachedSharedKey =
      '''((cached:)(@(?<sharedWith>($_charsInAtSign|$_allowedEmoji){1,55}):))(_*(?<entity>($_charsInEntity|$_allowedEmoji)+))\\.(?<namespace>$_charsInNamespace)@(?<owner>($_charsInAtSign|$_allowedEmoji){1,55})''';
  static const cachedPublicKey =
      '''(?<visibility>(cached:public:){1})((@(?<sharedWith>($_charsInAtSign|$_allowedEmoji){1,55}):))?(?<entity>($_charsInEntity|$_allowedEmoji)+)\\.(?<namespace>$_charsInNamespace)@(?<owner>($_charsInAtSign|$_allowedEmoji){1,55})''';
}

class RegexUtil {
  /// Returns a first matching key type after matching the key against regexes for each of the key type
  static KeyType keyType(String key) {
    // matches the key with public key regex.
    if (matchAll(Regexes.publicKey, key)) {
      return KeyType.publicKey;
    }
    // matches the key with private key regex.
    if (matchAll(Regexes.privateKey, key)) {
      return KeyType.privateKey;
    }
    // matches the key with self key regex.
    if (matchAll(Regexes.selfKey, key)) {
      Map<String, String> matches =
          RegexUtil.matchesByGroup(Regexes.selfKey, key);
      String? sharedWith = matches[RegexGroup.sharedWith.name()];
      // If owner is not specified set it to a empty string
      String? owner = matches[RegexGroup.owner.name()];
      if ((owner != null && owner.isNotEmpty) &&
          (sharedWith != null && sharedWith.isNotEmpty) &&
          owner != sharedWith) {
        return KeyType.sharedKey;
      }
      return KeyType.selfKey;
    }
    if (matchAll(Regexes.cachedPublicKey, key)) {
      return KeyType.cachedPublicKey;
    }
    if (matchAll(Regexes.cachedSharedKey, key)) {
      return KeyType.cachedSharedKey;
    }
    return KeyType.invalidKey;
  }

  /// Matches a regex against the input.
  /// Returns a true if the regex is matched and a false otherwise
  static bool matchAll(String regex, String input) {
    var regExp = RegExp(regex, caseSensitive: false);
    return regExp.hasMatch(input) &&
        regExp.stringMatch(input)!.length == input.length;
  }

  /// Returns a [Map] containing named groups and the matched values in the input
  /// Returns an empty [Map] if no matches are found
  static Map<String, String> matchesByGroup(String regex, String input) {
    var regExp = RegExp(regex, caseSensitive: false);
    var matches = regExp.allMatches(input);

    if (matches.isEmpty) {
      return <String, String>{};
    }

    var paramsMap = HashMap<String, String>();
    for (var f in matches) {
      for (var name in f.groupNames) {
        paramsMap.putIfAbsent(name,
            () => (f.namedGroup(name) != null) ? f.namedGroup(name)! : '');
      }
    }
    return paramsMap;
  }
}

/// Represents groups with in Regexes
/// See [Regexes]
enum RegexGroup { visibility, sharedWith, entity, namespace, owner }

extension RegexGroupToString on RegexGroup {
  String name() {
    return toString().split('.').last;
  }
}

import 'dart:convert';
import 'package:at_utils/src/utils/reg_exp_util.dart';
import 'package:crypto/crypto.dart';
import 'package:at_commons/at_commons.dart';

/// Utility class for atSign operations
class AtUtils {
  static final AtUtils _singleton = AtUtils._internal();

  factory AtUtils() {
    return _singleton;
  }

  AtUtils._internal();

  /// Apply all the rules on the provided atSign and return fixedAtSign.
  static String fixAtSign(String? atSign) {
    /// If the atSign is null or empty, throw an InvalidAtSignException.
    if (atSign == null || atSign == '') {
      throw InvalidAtSignException(AtMessage.noAtSign.text);
    }

    /// Convert the atSign to LowerCase.
    /// @sign must be always lowercase.
    atSign = atSign.toLowerCase();

    /// Check if the atSign contains `@`.
    /// If it doesn't contain `@`, throw an InvalidAtSignException.
    if (!atSign.contains('@')) {
      throw InvalidAtSignException(AtMessage.noAtSign.text);
    }

    /// Replace the `@` with empty char to
    /// check if the @sign has any more `@`.
    var noAT = atSign.replaceFirst('@', '');

    /// Check if the @sign has/contains any more `@`.
    /// If we find any more `@`, throw an InvalidAtSignException.
    if (noAT.contains(AtRegExp.atsign)) {
      throw InvalidAtSignException(AtMessage.moreThanOneAt.text);
    }

    /// Split the atSign with `@`.
    var split = atSign.split('@');

    /// Left part of the atSign after the spit.
    var left = split[0].toString();

    /// Right part of the atSign after the spit.
    /// And replace all `.` with empty char.
    var right = split[1].toString().replaceAll(r'.', '');

    /// If right part of the atSign is empty, throw an InvalidAtSignException.
    if (right.isEmpty) {
      throw InvalidAtSignException(AtMessage.noAtSign.text);
    }

    /// reconstruct @sign
    atSign = left + '@' + right;

    /// Check if the @sign has any special characters.
    /// If exists, throw an InvalidAtSignException.
    if (atSign.contains(AtRegExp.specialChar)) {
      throw InvalidAtSignException(AtMessage.reservedCharacterUsed.text);
    }

    /// White spaces characters not allowed in @signs
    /// If exists, throw an InvalidAtSignException.
    if (atSign.contains(AtRegExp.whiteSpaceChar)) {
      throw InvalidAtSignException(AtMessage.whiteSpaceNotAllowed.text);
    }

    /// ASCII Control characters not allowed in @signs
    /// If exists, throw an InvalidAtSignException.
    if (atSign.contains(AtRegExp.asciicontrolChar)) {
      throw InvalidAtSignException(AtMessage.controlCharacter.text);
    }

    /// Control characters not allowed in @signs
    /// If exists, throw an InvalidAtSignException.
    if (atSign.contains(AtRegExp.controlChar)) {
      throw InvalidAtSignException(AtMessage.controlCharacter.text);
    }
    return atSign;
  }

  /// Return AtSign by appending '@' at the beginning if not exists.
  static String? formatAtSign(String? atSign) {
    // verify whether atSign started with '@' or not
    if (atSign != null && !atSign.startsWith('@')) {
      atSign = '@$atSign';
    }
    return atSign;
  }

  /// Return the SHA256 of the atSign
  static String getShaForAtSign(String atsign) {
    /// encode the given atsign in to List<int> called as bytes
    var bytes = utf8.encode(atsign);

    return sha256.convert(bytes).toString();
  }
}

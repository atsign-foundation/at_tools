import 'package:at_commons/at_commons.dart';
import 'package:at_commons/src/verb/verb_builder.dart';
import 'package:at_commons/src/verb/verb_util.dart';

class NotifyVerbBuilder implements VerbBuilder {
  /// Key that represents a user's information. e.g phone, location, email etc.,
  String atKey;

  /// Value of the key typically in string format. Images, files, etc.,
  /// must be converted to unicode string before storing.
  dynamic value;

  /// AtSign to whom [atKey] has to be shared.
  String sharedWith;

  /// AtSign of the client user calling this builder.
  String sharedBy;

  /// if [isPublic] is true, then [atKey] is accessible by all atSigns.
  /// if [isPublic] is false, then [atKey] is accessible either by [sharedWith] or [sharedBy]
  bool isPublic = false;

  /// time in milliseconds after which [atKey] expires.
  int ttl;

  /// time in milliseconds after which [atKey] becomes active.
  int ttb;

  /// time in milliseconds to refresh [atKey].
  int ttr;

  OperationEnum operation;

  bool ccd;

  @override
  String buildCommand() {
    var command = 'notify:';

    if (operation != null) {
      command += '${getOperationName(operation)}:';
    }
    if (ttl != null) {
      command += 'ttl:${ttl}:';
    }
    if (ttb != null) {
      command += 'ttb:${ttb}:';
    }
    if (ttr != null) {
      ccd ??= false;
      command += 'ttr:${ttr}:ccd:${ccd}:';
    }
    if (sharedWith != null) {
      command += '${VerbUtil.formatAtSign(sharedWith)}:';
    }

    if (isPublic) {
      command += 'public:';
    }
    command += atKey;

    if (sharedBy != null) {
      command += '${VerbUtil.formatAtSign(sharedBy)}';
    }
    if (ttr != null && value != null) {
      command += ':${value}';
    }

    return '$command\n';
  }

  @override
  bool checkParams() {
    var isValid = true;
    if ((atKey == null) || (isPublic == true && sharedWith != null)) {
      isValid = false;
    }
    return isValid;
  }
}

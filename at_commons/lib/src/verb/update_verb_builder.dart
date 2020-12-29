import 'package:at_commons/src/verb/verb_util.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_commons/src/verb/verb_builder.dart';

/// Update builder generates a command to update [value] for a key [atKey] in the secondary server of [sharedBy].
/// Use [getBuilder] method if you want to convert command to a builder.
/// ```
///  //setting a public value for the key 'phone'
///  var updateBuilder = UpdateVerbBuilder()..isPublic=true
///  ..key='phone'
///  ..sharedBy='bob'
///  ..value='+1-1234';
///
///   //@bob setting a value for the key 'phone' to share with @alice
///  var updateBuilder = UpdateVerbBuilder()
///  ..sharedWith=’alice’
///  ..key='phone'
///  ..sharedBy='bob'
///  ..value='+1-5678';
/// ```
class UpdateVerbBuilder implements VerbBuilder {
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

  ///boolean variable to enable/disable cascade delete
  bool ccd;

  bool isBinary;

  /// boolean variable to indicate if the value is encrypted.
  /// True indicates encrypted value
  /// False indicates unencrypted value
  bool isEncrypted;

  String operation;

  @override
  String buildCommand() {
    var command = 'update:';
    if (ttl != null) {
      command += 'ttl:${ttl}:';
    }
    if (ttb != null) {
      command += 'ttb:${ttb}:';
    }
    if (ttr != null) {
      command += 'ttr:${ttr}:';
    }
    if (ccd != null) {
      command += 'ccd:${ccd}:';
    }
    if (isBinary != null) {
      command += 'isBinary:${isBinary}:';
    }
    if (isEncrypted != null) {
      command += 'isEncrypted:${isEncrypted}:';
    }
    if (isPublic) {
      command += 'public:';
    } else if (sharedWith != null) {
      command += '${VerbUtil.formatAtSign(sharedWith)}:';
    }
    command += atKey;

    if (sharedBy != null) {
      command += '${VerbUtil.formatAtSign(sharedBy)}';
    }
    command += ' ${value}\n';
    return command;
  }

  String buildCommandForMeta() {
    var command = 'update:meta:';
    if (isPublic) {
      command += 'public:';
    } else if (sharedWith != null) {
      command += '${VerbUtil.formatAtSign(sharedWith)}:';
    }
    command += atKey;
    if (sharedBy != null) {
      command += '${VerbUtil.formatAtSign(sharedBy)}';
    }
    if (ttl != null) {
      command += ':ttl:${ttl}';
    }
    if (ttb != null) {
      command += ':ttb:${ttb}';
    }
    if (ttr != null) {
      command += ':ttr:${ttr}';
    }
    if (ccd != null) {
      command += ':ccd:${ccd}';
    }
    if (isBinary != null) {
      command += ':isBinary:${isBinary}';
    }
    if (isEncrypted != null) {
      command += ':isEncrypted:${isEncrypted}';
    }
    command += '\n';
    return command;
  }

  static UpdateVerbBuilder getBuilder(String command) {
    var builder = UpdateVerbBuilder();
    var verbParams;
    if (command.contains(UPDATE_META)) {
      verbParams = VerbUtil.getVerbParam(VerbSyntax.update_meta, command);
      builder.operation = UPDATE_META;
    } else {
      verbParams = VerbUtil.getVerbParam(VerbSyntax.update, command);
    }
    if (verbParams == null) {
      return null;
    }
    builder.isPublic = command.contains('public:');
    builder.sharedWith = VerbUtil.formatAtSign(verbParams[FOR_AT_SIGN]);
    builder.sharedBy = VerbUtil.formatAtSign(verbParams[AT_SIGN]);
    builder.atKey = verbParams[AT_KEY];
    builder.value = verbParams[AT_VALUE];
    if (verbParams[AT_TTL] != null) builder.ttl = int.parse(verbParams[AT_TTL]);
    if (verbParams[AT_TTB] != null) builder.ttb = int.parse(verbParams[AT_TTB]);
    if (verbParams[AT_TTR] != null) builder.ttr = int.parse(verbParams[AT_TTR]);
    if (verbParams[CCD] != null) {
      builder.ccd = _getBoolVerbParams(verbParams[CCD]);
    }
    if (verbParams[IS_BINARY] != null) {
      builder.isBinary = _getBoolVerbParams(verbParams[IS_BINARY]);
    }
    if (verbParams[IS_ENCRYPTED] != null) {
      builder.isEncrypted = _getBoolVerbParams(verbParams[IS_ENCRYPTED]);
    }
    return builder;
  }

  @override
  bool checkParams() {
    var isValid = true;
    if ((atKey == null || value == null) ||
        (isPublic == true && sharedWith != null)) {
      isValid = false;
    }
    return isValid;
  }

  static bool _getBoolVerbParams(String arg1) {
    if (arg1.toLowerCase() == 'true') {
      return true;
    }
    return false;
  }
}

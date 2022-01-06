import 'dart:convert';

import 'package:at_commons/at_commons.dart';
import 'package:at_commons/src/verb/verb_builder.dart';
import 'package:at_commons/src/verb/verb_util.dart';

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
  late AtKey atKey;

  /// Value of the key typically in string format. Images, files, etc.,
  /// must be converted to unicode string before storing.
  dynamic value;

  String? operation;

  bool isJson = false;

  @override
  String buildCommand() {
    if (isJson) {
      var updateParams = UpdateParams();
      var key = '';
      if (atKey.sharedWith != null) {
        key += '${VerbUtil.formatAtSign(atKey.sharedWith)}:';
      }
      key += atKey.key;
      if (atKey.sharedBy != null) {
        key += '${VerbUtil.formatAtSign(atKey.sharedBy)}';
      }
      updateParams.atKey = key;
      updateParams.value = value;
      updateParams.sharedBy = atKey.sharedBy;
      updateParams.sharedWith = atKey.sharedWith;
      if (atKey.metadata != null) {
        var metadata = Metadata();
        metadata.ttr = atKey.metadata!.ttr;
        metadata.ttb = atKey.metadata!.ttb;
        metadata.ttl = atKey.metadata!.ttl;
        metadata.dataSignature = atKey.metadata!.dataSignature;
        metadata.isEncrypted = atKey.metadata!.isEncrypted;
        metadata.ccd = atKey.metadata!.ccd;
        metadata.isPublic = atKey.metadata!.isPublic;
        metadata.sharedKeyStatus = atKey.metadata!.sharedKeyStatus;
        updateParams.metadata = metadata;
      }
      var json = updateParams.toJson();
      var command = 'update:json:${jsonEncode(json)}\n';
      print('update json:$command');
      return command;
    }
    //If JSON is false.
    var command = 'update:';
    command += _getMetadataCommand(atKey.metadata);

    if (atKey.metadata != null && atKey.metadata!.isPublic) {
      command += 'public:';
    } else if (atKey.sharedWith != null) {
      command += '${VerbUtil.formatAtSign(atKey.sharedWith)}:';
    }
    command += atKey.key;

    if (atKey.sharedBy != null) {
      command += '${VerbUtil.formatAtSign(atKey.sharedBy)}';
    }
    if (value is String) {
      value = VerbUtil.replaceNewline(value);
    }
    command += ' $value\n';
    return command;
  }

  String buildCommandForMeta() {
    var command = 'update:meta:';
    if (atKey.metadata != null && atKey.metadata!.isPublic) {
      command += 'public:';
    } else if (atKey.sharedWith != null) {
      command += '${VerbUtil.formatAtSign(atKey.sharedWith)}:';
    }
    command += atKey.key;
    if (atKey.sharedBy != null) {
      command += '${VerbUtil.formatAtSign(atKey.sharedBy)}';
    }
    command += _getMetadataCommand(atKey.metadata);
    command += '\n';
    return command;
  }

  static UpdateVerbBuilder? getBuilder(String command) {
    var atKey = AtKey()..metadata = Metadata();
    var builder = UpdateVerbBuilder()..atKey = atKey;
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
    builder.atKey.metadata!.isPublic = command.contains('public:');
    builder.atKey.sharedWith = VerbUtil.formatAtSign(verbParams[FOR_AT_SIGN]);
    builder.atKey.sharedBy = VerbUtil.formatAtSign(verbParams[AT_SIGN]);
    builder.atKey = verbParams[AT_KEY];
    builder.value = verbParams[AT_VALUE];
    if (builder.value is String) {
      builder.value = VerbUtil.replaceNewline(builder.value);
    }
    if (verbParams[AT_TTL] != null) {
      builder.atKey.metadata!.ttl = int.parse(verbParams[AT_TTL]);
    }
    if (verbParams[AT_TTB] != null) {
      builder.atKey.metadata!.ttb = int.parse(verbParams[AT_TTB]);
    }
    if (verbParams[AT_TTR] != null) {
      builder.atKey.metadata!.ttr = int.parse(verbParams[AT_TTR]);
    }
    if (verbParams[CCD] != null) {
      builder.atKey.metadata!.ccd = _getBoolVerbParams(verbParams[CCD]);
    }
    if (verbParams[PUBLIC_DATA_SIGNATURE] != null) {
      builder.atKey.metadata!.dataSignature = verbParams[PUBLIC_DATA_SIGNATURE];
    }
    if (verbParams[IS_BINARY] != null) {
      builder.atKey.metadata!.isBinary =
          _getBoolVerbParams(verbParams[IS_BINARY]);
    }
    if (verbParams[IS_ENCRYPTED] != null) {
      builder.atKey.metadata!.isEncrypted =
          _getBoolVerbParams(verbParams[IS_ENCRYPTED]);
    }
    return builder;
  }

  String _getMetadataCommand(Metadata? metadata) {
    String metadataCommand = '';
    if (metadata == null) {
      return '';
    }
    if (metadata.ttl != null) {
      metadataCommand += 'ttl:${metadata.ttl}:';
    }
    if (metadata.ttb != null) {
      metadataCommand += 'ttb:${metadata.ttb}:';
    }
    if (metadata.ttr != null) {
      metadataCommand += 'ttr:${metadata.ttr}:';
    }
    if (metadata.ccd != null) {
      metadataCommand += 'ccd:${metadata.ccd}:';
    }
    if (metadata.dataSignature != null) {
      metadataCommand += 'dataSignature:${metadata.dataSignature}:';
    }
    if (metadata.isBinary) {
      metadataCommand += 'isBinary:${metadata.isBinary}:';
    }
    if (metadata.isEncrypted) {
      metadataCommand += 'isEncrypted:${metadata.isEncrypted}:';
    }
    return metadataCommand;
  }

  @override
  bool checkParams() {
    var isValid = true;
    if ((value == null) ||
        (atKey.metadata!.isPublic == true && atKey.sharedWith != null)) {
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

import 'dart:collection';
import 'dart:convert';

import 'package:at_commons/at_commons.dart';
import 'package:at_commons/src/verb/metadata_using_verb_builder.dart';

/// Update builder generates a command to update [value] for a key [atKey] in the secondary server of [sharedBy].
/// Use [getBuilder] method if you want to convert command to a builder.
///
///  * Setting a public value for the key 'phone'
///
///  * When isPublic is set to true, throws [InvalidAtKeyException] if isLocal is set to true or sharedWith is populated
///```dart
///  var updateBuilder = UpdateVerbBuilder()
///  ..isPublic=true
///  ..key='phone'
///  ..sharedBy='bob'
///  ..value='+1-1234';
///```
///
///   * @bob setting a value for the key 'phone' to share with @alice
///
///   * When sharedWith is populated, throws [InvalidAtKeyException] if isLocal or isPublic is set to true
///```dart
///  var updateBuilder = UpdateVerbBuilder()
///  ..sharedWith=’alice’
///  ..key='phone'
///  ..sharedBy='bob'
///  ..value='+1-5678';
///```
///
/// * Creating a local key for storing data that does not sync
///
/// * When isLocal is set to true, throws [InvalidAtKeyException] if isPublic is set to true or sharedWith is populated
///```dart
///  var updateBuilder = UpdateVerbBuilder()
///                      ..isLocal = true
///                      ..key = 'preferences'
///                      ..sharedBy = '@bob'
///                      ..value = jsonEncode(myPrefObj)
///```
class UpdateVerbBuilder extends MetadataUsingVerbBuilder {
  /// Value of the key typically in string format. Images, files, etc.,
  /// must be converted to unicode string before storing.
  dynamic value;

  /// See [AtKey.isLocal]
  bool get isLocal => atKeyObj.isLocal;

  /// See [AtKey.isLocal]
  set isLocal(bool b) => atKeyObj.isLocal = b;

  String? operation;

  bool isJson = false;

  @override
  String buildCommand() {
    String atKeyName = buildKey();
    if (isJson) {
      var updateParams = UpdateParams()
        ..atKey = atKeyName
        ..value = value
        ..sharedBy = sharedBy
        ..sharedWith = sharedWith
        ..metadata = metadata;
      var json = updateParams.toJson();
      var command = 'update:json:${jsonEncode(json)}\n';
      return command;
    } else {
      var metadataFragment = atKeyObj.metadata!.toAtProtocolFragment();
      var command = 'update$metadataFragment:$atKeyName $value\n';
      return command;
    }
  }

  /// Get the string representation (e.g. `@bob:city.address.my_app@alice`) of the key
  /// for which this update command is being built.
  ///
  /// First of all calls [validateKey]. If validation fails an exception will be thrown. If not
  /// then we return the string representation of the key.
  String buildKey() {
    validateKey();
    return super.atKeyObj.toString();
  }

  String buildCommandForMeta() {
    String atKeyName = buildKey();
    var metadataFragment = atKeyObj.metadata!.toAtProtocolFragment();
    var command = 'update:meta:$atKeyName$metadataFragment\n';
    return command;
  }

  static UpdateVerbBuilder fromVerbParams(Map<String, String?> verbParams, {bool forUpdateMeta=false}) {
    var builder = UpdateVerbBuilder();

    if (forUpdateMeta) {
      builder.operation = UPDATE_META;
    }

    builder.isPublic = verbParams[PUBLIC_SCOPE_PARAM] == 'public';
    builder.sharedWith = VerbUtil.formatAtSign(verbParams[FOR_AT_SIGN]);
    builder.sharedBy = VerbUtil.formatAtSign(verbParams[AT_SIGN]);
    builder.atKey = verbParams[AT_KEY];
    builder.value = verbParams[AT_VALUE];
    if (builder.value is String) {
      builder.value = VerbUtil.replaceNewline(builder.value);
    }

    builder.setMetaDataFromParams(verbParams);

    return builder;
  }

  static UpdateVerbBuilder getBuilder(String command) {
    if (command != command.trim()) {
      throw IllegalArgumentException(
          'Commands may not have leading or trailing whitespace');
    }
    HashMap<String, String?>? verbParams;
    bool forUpdateMeta = false;
    if (command.contains(UPDATE_META)) {
      forUpdateMeta = true;
      verbParams = VerbUtil.getVerbParam(VerbSyntax.update_meta, command);
    } else {
      verbParams = VerbUtil.getVerbParam(VerbSyntax.update, command);
    }
    if (verbParams == null) {
      throw IllegalArgumentException(
          'UpdateVerbBuilder.getBuilder: Failed to extract any parameters from command');
    }

    return fromVerbParams(verbParams, forUpdateMeta: forUpdateMeta);
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateVerbBuilder &&
          runtimeType == other.runtimeType &&
          atKey == other.atKey &&
          value == other.value &&
          sharedWith == other.sharedWith &&
          sharedBy == other.sharedBy &&
          isPublic == other.isPublic &&
          isBinary == other.isBinary &&
          isEncrypted == other.isEncrypted &&
          operation == other.operation &&
          isJson == other.isJson &&
          isLocal == other.isLocal &&
          ttl == other.ttl &&
          ttb == other.ttb &&
          ttr == other.ttr &&
          ccd == other.ccd &&
          dataSignature == other.dataSignature &&
          sharedKeyStatus == other.sharedKeyStatus &&
          sharedKeyEncrypted == other.sharedKeyEncrypted &&
          pubKeyChecksum == other.pubKeyChecksum &&
          encoding == other.encoding &&
          encKeyName == other.encKeyName &&
          encAlgo == other.encAlgo &&
          ivNonce == other.ivNonce &&
          skeEncKeyName == other.skeEncKeyName &&
          skeEncAlgo == other.skeEncAlgo;

  @override
  int get hashCode =>
      atKey.hashCode ^
      value.hashCode ^
      sharedWith.hashCode ^
      sharedBy.hashCode ^
      isPublic.hashCode ^
      isBinary.hashCode ^
      isEncrypted.hashCode ^
      operation.hashCode ^
      isJson.hashCode ^
      isLocal.hashCode ^
      ttl.hashCode ^
      ttb.hashCode ^
      ttr.hashCode ^
      ccd.hashCode ^
      dataSignature.hashCode ^
      sharedKeyStatus.hashCode ^
      sharedKeyEncrypted.hashCode ^
      pubKeyChecksum.hashCode ^
      encoding.hashCode ^
      encKeyName.hashCode ^
      encAlgo.hashCode ^
      ivNonce.hashCode ^
      skeEncKeyName.hashCode ^
      skeEncAlgo.hashCode;
}

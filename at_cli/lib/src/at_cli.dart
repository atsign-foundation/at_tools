import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:at_client/at_client.dart';
import 'package:at_cli/src/preference.dart';
import 'package:encrypt/encrypt.dart';
import 'package:at_commons/at_builders.dart';

/// A class to execute verbs from commandline.
class AtCli {
  static final AtCli _singleton = AtCli._internal();

  AtCli._internal();

  factory AtCli.getInstance() {
    return _singleton;
  }

  var _atSign;

  var _aesEncryptionKey;
  var _pkamPrivateKey;

  var _atClientImpl;

  /// Method to create Atlookup instance with the preferences
  Future<void> init(
      String currentAtSign, AtCliPreference atCliPreference) async {
    _atSign = currentAtSign;

    var keysJSON = await getSecretFromAtKeys(atCliPreference.authKeyFile);
    _aesEncryptionKey = keysJSON['selfEncryptionKey'].toString().trim();
    _pkamPrivateKey =
        decryptValue(keysJSON['aesPkamPrivateKey'], _aesEncryptionKey).trim();

    var atClientPreference =
        _getAtClientPreference(_pkamPrivateKey, atCliPreference);

    await AtClientImpl.createClient(
        _atSign, atCliPreference.namespace, atClientPreference);

    _atClientImpl = await AtClientImpl.getClient(_atSign);
    if (_atClientImpl == null) {
      throw Exception('unable to create at client instance');
    }
  }

  factory AtCli() {
    return _singleton;
  }

  /// Method to execute verb
  /// input - Commandline arguments and values
  /// return value - verb result
  Future<dynamic> execute(String currentAtSign, AtCliPreference atCliPreference,
      ArgResults arguments) async {
    await init(currentAtSign, atCliPreference);
    var verb = arguments['verb'];
    bool auth = arguments['auth'];
    var result;
    try {
      switch (verb) {
        case 'update':
          var builder = UpdateVerbBuilder();
          if (arguments['public']) {
            builder.isPublic = true;
          }
          builder.atKey = arguments['key'];
          builder.sharedBy = currentAtSign;
          builder.sharedWith = arguments['shared_with'];
          builder.value = arguments['value'];
          var command = builder.buildCommand();
          result = await _atClientImpl!
              .getRemoteSecondary()!
              .executeCommand(command, auth: true);
          break;
        case 'llookup':
          var builder = LLookupVerbBuilder();
          builder.atKey = arguments['key'];
          builder.sharedBy = _atSign;
          builder.sharedWith = arguments['shared_with'];
          builder.isPublic = arguments['public'];
          builder.sharedBy = (arguments['shared_by'] != null)
              ? arguments['shared_by']
              : _atSign;
          var command = builder.buildCommand();
          result = await _atClientImpl!
              .getRemoteSecondary()!
              .executeCommand(command, auth: true);
          break;
        case 'lookup':
          var builder = LookupVerbBuilder();
          builder.atKey = arguments['key'];
          builder.sharedBy = (arguments['shared_by'] != null)
              ? arguments['shared_by']
              : _atSign;
          var command = builder.buildCommand();
          result = await _atClientImpl!
              .getRemoteSecondary()!
              .executeCommand(command, auth: true);
          break;
        case 'plookup':
          var builder = PLookupVerbBuilder();
          builder.atKey = arguments['key'];
          builder.sharedBy = (arguments['shared_by'] != null)
              ? arguments['shared_by']
              : _atSign;
          var command = builder.buildCommand();
          result = await _atClientImpl!
              .getRemoteSecondary()!
              .executeCommand(command, auth: true);
          break;
        case 'delete':
          var builder = DeleteVerbBuilder();
          builder.atKey = arguments['key'];
          builder.sharedWith = arguments['shared_with'];
          builder.isPublic = arguments['public'];
          var command = builder.buildCommand();
          result = await _atClientImpl!
              .getRemoteSecondary()!
              .executeCommand(command, auth: true);
          break;
        case 'scan':
          var builder = ScanVerbBuilder();
          builder.regex = arguments['regex'];
          builder.sharedBy = arguments['shared_by'];
          var command = builder.buildCommand();
          result = await _atClientImpl!
              .getRemoteSecondary()!
              .executeCommand(command, auth: auth);
          break;
      }
      return result;
    } on Exception {
      rethrow;
    }
  }

  /// Method to execute command
  /// input - command and isAuth
  /// return value - command response
  Future<String> executeCommand(
      String currentAtSign, AtCliPreference atCliPreference, String command,
      {bool isAuth = false}) async {
    var result;
    await init(currentAtSign, atCliPreference);
    try {
      command = command + '\n';
      if (isAuth) {
        result = await _atClientImpl!
            .getRemoteSecondary()!
            .executeCommand(command, auth: true);
      } else {
        result =
            await _atClientImpl!.getRemoteSecondary()!.executeCommand(command);
      }
    } on Exception {
      rethrow;
    }
    return result;
  }

  String getAuthKey(String atSign, String path) {
    String contents;
    try {
      contents = File(path).readAsStringSync();
    } catch (error) {
      rethrow;
    }
    return contents;
  }

  ///Method to get pkam key and encryption key from atKeys file
  Future<dynamic> getSecretFromAtKeys(String filePath) async {
    try {
      var fileContents = File(filePath).readAsStringSync();
      return json.decode(fileContents);
    } on Exception catch (e) {
      throw Exception('Exception while reading atKeys file : $e');
    }
  }

  String decryptValue(String encryptedValue, String decryptionKey) {
    var aesKey = AES(Key.fromBase64(decryptionKey));
    var decrypter = Encrypter(aesKey);
    var iv2 = IV.fromLength(16);
    return decrypter.decrypt64(encryptedValue, iv: iv2);
  }

  AtClientPreference _getAtClientPreference(
      String privateKey, AtCliPreference atCliPreference) {
    var preference = AtClientPreference();
    preference.isLocalStoreRequired = false;
    preference.privateKey = preference.rootDomain = atCliPreference.rootDomain;
    preference.outboundConnectionTimeout = 60000;
    preference.privateKey = privateKey;
    return preference;
  }
}

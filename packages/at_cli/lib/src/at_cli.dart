import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:args/args.dart';
import 'package:at_cli/src/command_line_parser.dart';
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

  late String _atSign;

  late String _aesEncryptionKey;
  late String _pkamPrivateKey;

  AtClient? _atClientImpl;

  /// Method to create AtLookup instance with the preferences
  Future<void> init(
      String currentAtSign, AtCliPreference atCliPreference) async {
    _atSign = currentAtSign;

    var keysJSON = await getSecretFromAtKeys(atCliPreference.authKeyFile);
    _aesEncryptionKey = keysJSON['selfEncryptionKey'].toString().trim();
    _pkamPrivateKey =
        decryptValue(keysJSON['aesPkamPrivateKey'], _aesEncryptionKey).trim();

    var atClientPreference =
        _getAtClientPreference(_pkamPrivateKey, atCliPreference);

    AtClientManager atClientManager = AtClientManager.getInstance();
    await atClientManager.setCurrentAtSign(
        _atSign, atCliPreference.namespace, atClientPreference);

    _atClientImpl = atClientManager.atClient;
    if (_atClientImpl == null) {
      throw Exception('unable to create at client instance');
    }
  }

  /// Method to execute verb
  /// input - Commandline arguments and values
  /// return value - verb result
  Future<dynamic> execute(
      AtCliPreference atCliPreference, ArgResults arguments) async {
    var verb = arguments['verb'];
    bool auth = arguments['auth'];
    dynamic result;
    try {
      switch (verb) {
        case 'update':
          var builder = UpdateVerbBuilder();
          if (arguments['public']) {
            builder.isPublic = true;
          }
          builder.atKey = arguments['key'];
          builder.sharedBy = _atSign;
          builder.sharedWith = arguments['shared_with'];
          builder.value = arguments['value'];
          if (!builder.checkParams()) {
            throw Exception(
                'Invalid command \n ${CommandLineParser.getUsage()}');
          }
          var command = builder.buildCommand();
          if (atCliPreference.authRequired && atCliPreference.cache) {
            result = await _atClientImpl!
                .getLocalSecondary()!
                .executeVerb(builder, sync: true);
          } else {
            result = await _atClientImpl!
                .getRemoteSecondary()!
                .executeCommand(command, auth: auth);
          }
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
          if (!builder.checkParams()) {
            throw Exception(
                'Invalid command \n ${CommandLineParser.getUsage()}');
          }
          var command = builder.buildCommand();
          if (atCliPreference.authRequired && atCliPreference.cache) {
            result = await _atClientImpl!
                .getLocalSecondary()!
                .executeVerb(builder, sync: true);
          } else {
            result = await _atClientImpl!
                .getRemoteSecondary()!
                .executeCommand(command, auth: auth);
          }
          break;
        case 'lookup':
          var builder = LookupVerbBuilder();
          builder.atKey = arguments['key'];
          builder.sharedBy = (arguments['shared_by'] != null)
              ? arguments['shared_by']
              : _atSign;
          if (!builder.checkParams()) {
            throw Exception(
                'Invalid command \n ${CommandLineParser.getUsage()}');
          }
          var command = builder.buildCommand();
          if (atCliPreference.authRequired && atCliPreference.cache) {
            result = await _atClientImpl!
                .getLocalSecondary()!
                .executeVerb(builder, sync: true);
          } else {
            result = await _atClientImpl!
                .getRemoteSecondary()!
                .executeCommand(command, auth: auth);
          }
          break;
        case 'plookup':
          var builder = PLookupVerbBuilder();
          builder.atKey = arguments['key'];
          builder.sharedBy = (arguments['shared_by'] != null)
              ? arguments['shared_by']
              : _atSign;
          if (!builder.checkParams()) {
            throw Exception(
                'Invalid command \n ${CommandLineParser.getUsage()}');
          }
          var command = builder.buildCommand();
          if (atCliPreference.authRequired && atCliPreference.cache) {
            result = await _atClientImpl!
                .getLocalSecondary()!
                .executeVerb(builder, sync: true);
          } else {
            result = await _atClientImpl!
                .getRemoteSecondary()!
                .executeCommand(command, auth: auth);
          }
          break;
        case 'delete':
          var builder = DeleteVerbBuilder();
          builder.atKey = arguments['key'];
          builder.sharedWith = arguments['shared_with'];
          builder.isPublic = arguments['public'];
          builder.sharedBy = (arguments['shared_by'] != null)
              ? arguments['shared_by']
              : _atSign;
          if (!builder.checkParams()) {
            throw Exception(
                'Invalid command \n ${CommandLineParser.getUsage()}');
          }
          var command = builder.buildCommand();
          if (atCliPreference.authRequired && atCliPreference.cache) {
            result = await _atClientImpl!
                .getLocalSecondary()!
                .executeVerb(builder, sync: true);
          } else {
            result = await _atClientImpl!
                .getRemoteSecondary()!
                .executeCommand(command, auth: auth);
          }
          break;
        case 'scan':
          var builder = ScanVerbBuilder();
          builder.regex = arguments['regex'];
          builder.sharedBy = arguments['shared_by'];
          var command = builder.buildCommand();
          if (!builder.checkParams()) {
            throw Exception(
                'Invalid command \n ${CommandLineParser.getUsage()}');
          }
          if (atCliPreference.authRequired && atCliPreference.cache) {
            result = await _atClientImpl!
                .getLocalSecondary()!
                .executeVerb(builder, sync: true);
          } else {
            result = await _atClientImpl!
                .getRemoteSecondary()!
                .executeCommand(command, auth: auth);
          }
          break;
        case 'sync':
          if (atCliPreference.authRequired && atCliPreference.cache) {
            Completer<bool> completer = Completer();
            var prefs = _atClientImpl!.getPreferences() ?? AtClientPreference();
            prefs.namespace = arguments['regex'];
            _atClientImpl!.setPreferences(prefs);
            _atClientImpl!.syncService
                .addProgressListener(ProgressListener(completer));
            _atClientImpl!.syncService.sync();
            result = (await completer.future).toString();
          }
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
    dynamic result;
    try {
      command = command + '\n';
      result = await _atClientImpl!
          .getRemoteSecondary()!
          .executeCommand(command, auth: isAuth);
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
    var iv2 = IV(Uint8List(16));
    return decrypter.decrypt64(encryptedValue, iv: iv2);
  }

  AtClientPreference _getAtClientPreference(
      String privateKey, AtCliPreference atCliPreference) {
    var preference = AtClientPreference();
    preference.isLocalStoreRequired = atCliPreference.cache;
    if (atCliPreference.cache) {
      preference.hiveStoragePath = atCliPreference.cacheDir;
      preference.commitLogPath = atCliPreference.cacheDir;
    }

    preference.privateKey = preference.rootDomain = atCliPreference.rootDomain;
    preference.outboundConnectionTimeout = 60000;
    preference.privateKey = privateKey;
    return preference;
  }
}

class ProgressListener extends SyncProgressListener {
  final Completer<bool> completer;
  ProgressListener(this.completer);

  @override
  void onSyncProgressEvent(SyncProgress syncProgress) {
    if (syncProgress.syncStatus == SyncStatus.success ||
        syncProgress.syncStatus == SyncStatus.failure) {
      completer.complete(syncProgress.syncStatus == SyncStatus.success);
    }
  }
}

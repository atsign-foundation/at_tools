import 'dart:io';
import 'package:args/args.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_cli/src/preference.dart';
import 'package:at_lookup/at_lookup.dart';

/// A class to execute verbs from commandline.
class AtCli {
  static final AtCli _singleton = AtCli._internal();

  AtCli._internal();

  factory AtCli.getInstance() {
    return _singleton;
  }

  var _atSign;

  AtLookupImpl? _atLookup;

  /// Method to create Atlookup instance with the preferences
  void init(String currentAtSign, AtCliPreference preference) async {
    _atSign = currentAtSign;
    var authKey = getAuthKey(currentAtSign, preference.authKeyFile);
    if (preference.authMode == 'pkam') {
      _atLookup = AtLookupImpl(
          _atSign, preference.rootDomain, preference.rootPort,
          privateKey: authKey.trim());
    } else if (preference.authMode == 'cram') {
      _atLookup = AtLookupImpl(
          _atSign, preference.rootDomain, preference.rootPort,
          cramSecret: authKey.trim());
    } else {
      throw Exception('No authentication specified');
    }
  }

  factory AtCli() {
    return _singleton;
  }

  /// Method to execute verb
  /// input - Commandline arguments and values
  /// return value - verb result
  Future<dynamic> execute(ArgResults arguments) async {
    var verb = arguments['verb'];
    var result;
    try {
      switch (verb) {
        case 'update':
          var key = arguments['key'];
          var value = arguments['value'];
          var isPublic = arguments['public'];
          var sharedWith = arguments['shared_with'];
          var metadata;
          if (isPublic == 'true') {
            metadata = Metadata()..isPublic = true;
          }
          result = await _atLookup!
              .update(key, value, sharedWith: sharedWith, metadata: metadata);
          break;
        case 'llookup':
          var key = arguments['key'];
          var sharedWith = arguments['shared_with'];
          var isPublic = arguments['public'];
          var sharedBy = (arguments['shared_by'] != null)
              ? arguments['shared_by']
              : _atSign;
          result = await _atLookup!.llookup(key,
              isPublic: isPublic == 'true',
              sharedWith: sharedWith,
              sharedBy: sharedBy);
          break;
        case 'lookup':
          var key = arguments['key'];
          var sharedBy = (arguments['shared_by'] != null)
              ? arguments['shared_by']
              : _atSign;
          result = await _atLookup!.lookup(key, sharedBy);
          break;
        case 'plookup':
          var key = arguments['key'];
          var sharedBy = (arguments['shared_by'] != null)
              ? arguments['shared_by']
              : _atSign;
          result = await _atLookup!.plookup(key, sharedBy);
          break;
        case 'delete':
          var key = arguments['key'];
          var sharedWith = arguments['shared_with'];
          var isPublic = arguments['public'];
          result = await _atLookup!.delete(key,
              sharedWith: sharedWith, isPublic: isPublic == 'true');
          break;
        case 'scan':
          var regex = arguments['regex'];
          var sharedBy = arguments['shared_by'];
          await _atLookup!
              .scan(
                  regex: regex,
                  sharedBy: sharedBy,
                  auth: arguments['auth'] == 'true')
              .then((scan_result) {
            result = scan_result;
          }).catchError((scan_error) {
            result = _handleError(scan_error);
          });
          break;
      }
      return result;
    } on Exception {
      rethrow;
    }
  }

  String _handleError(AtLookUpException exception) {
    return '${exception.errorCode}-${exception.errorMessage}';
  }

  /// Method to execute command
  /// input - command and isAuth
  /// return value - command response
  Future<String> executeCommand(String command, {bool isAuth = false}) async {
    var result;
    try {
      command = command + '\n';
      if (isAuth) {
        result = await _atLookup!.executeCommand(command, auth: true);
      } else {
        result = await _atLookup!.executeCommand(command);
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
}

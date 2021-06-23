import 'package:at_commons/at_builders.dart';

class SyncVerbBuilder implements VerbBuilder {
  int commitId = -1;

  String regex = '';

  bool isStream = false;

  @override
  String buildCommand() {
    var command = 'sync:';
    if (isStream) {
      command += 'stream:';
    }
    command += '$commitId';
    if (regex.isNotEmpty) {
      command += ':$regex';
    }
    command += '\n';
    return command;
  }

  @override
  bool checkParams() {
    return true;
  }
}

import 'package:at_commons/at_builders.dart';

class SyncVerbBuilder implements VerbBuilder {
  int? commitId;

  String? regex;

  bool? isStream;

  @override
  String buildCommand() {
    var command = 'sync:';
    if (isStream!) {
      command += 'stream:';
    }
    command += '$commitId';
    if (regex != null && regex!.isNotEmpty) {
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

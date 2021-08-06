import 'package:at_commons/at_builders.dart';

class SyncVerbBuilder implements VerbBuilder {
  late String commitId;

  String? regex;

  bool isStream = false;

  @override
  String buildCommand() {
    String command = 'sync:';
    if (isStream) {
      command += 'stream:';
    }
    command += commitId;
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

import 'package:at_commons/src/verb/verb_builder.dart';
import 'package:at_commons/src/verb/verb_util.dart';

/// This builder generates a command to configure block list entries in the secondary server.
/// If an @sign is added to the block list then connections to the secondary will not be accepted.
/// ```
/// e.g to block alice from accessing bob's keys
/// var builder = ConfigVerbBuilder()..block = '@alice';
/// ```
class ConfigVerbBuilder implements VerbBuilder {
  String? configType;
  String? operation;
  List<String>? atSigns;
  @override
  String buildCommand() {
    String command = 'config:';
    command += '$configType:';
    if (operation == 'show') {
      command += operation!;
    } else {
      command += '$operation:';
    }
    if (atSigns != null && atSigns!.isNotEmpty) {
      for (String atSign in atSigns!) {
        command += VerbUtil.formatAtSign(atSign)!;
      }
    }
    command = command.trim();
    command = command + '\n';
    return command;
  }

  @override
  bool checkParams() {
    // TODO: implement checkParams
    return true;
  }
}

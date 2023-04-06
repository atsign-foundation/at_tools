import 'dart:io';
import 'package:args/args.dart';
import 'package:at_cli/at_cli.dart';
import 'package:at_cli/src/command_line_parser.dart';
import 'package:at_cli/src/preference.dart';
import 'package:at_cli/src/config_util.dart';
import 'package:at_utils/at_logger.dart';

void main(List<String> arguments) async {
  AtSignLogger.root_level = 'severe';
  await ConfigUtil.init();
  try {
    var parsedArgs = CommandLineParser.getParserResults(arguments);
    if (parsedArgs == null || parsedArgs.arguments.isEmpty) {
      print('Usage: \n${CommandLineParser.getUsage()}');
      exit(0);
    }
    var currentAtSign = _getCurrentAtSign(parsedArgs).trim();
    var preferences = await _getAtCliPreference(parsedArgs);
    if (!(await File(preferences.authKeyFile).exists())) {
      print('Given Authentication key file is not exists. '
          '\nPlease update correct file path in config or provide as commandline argument');
      print('Usage: \n ${CommandLineParser.getUsage()}');
      exit(0);
    }
    await AtCli.getInstance().init(currentAtSign, preferences);
    dynamic result;
    // If a verb is provided, call execute method with arguments
    // Else if command is provided as argument, we'll execute command directly.
    if (parsedArgs['verb'] != null) {
      result = await AtCli.getInstance().execute(preferences, parsedArgs);
    } else if (parsedArgs['command'] != null) {
      var command = parsedArgs['command'];
      var auth = parsedArgs['auth'];
      result = await AtCli.getInstance()
          .executeCommand(currentAtSign, preferences, command, isAuth: auth);
    } else {
      print('Invalid command. Verb or command not entered');
    }
    result =
        (result != null) ? result.toString().replaceFirst('data:', '') : result;
    print(result);
    exit(0);
  } on Exception catch (exception) {
    print('Exception while running verb : ${exception.toString()}');
  }
}

String _getCurrentAtSign(ArgResults arguments) {
  return ((arguments['atsign'] != null)
      ? arguments['atsign']
      : ConfigUtil.getYaml()!['auth']['at_sign']);
}

String getCommand(ArgResults arguments) {
  return arguments.toString();
}

Future<AtCliPreference> _getAtCliPreference(ArgResults? parsedArgs) async {
  var rootDomainFromConfig = ConfigUtil.getYaml()!['root_server']['host'];
  var preferences = AtCliPreference();
  if (rootDomainFromConfig != null) {
    preferences.rootDomain = rootDomainFromConfig.trim();
  }

  preferences.authRequired = parsedArgs!['auth'];

  preferences.authMode = ((parsedArgs['mode'] != null)
      ? parsedArgs['mode']
      : ConfigUtil.getYaml()!['auth']['mode']);

  preferences.authKeyFile = ((parsedArgs['authKeyFile'] != null)
      ? parsedArgs['authKeyFile']
      : ConfigUtil.getYaml()!['auth']['key_file_location']);

  return preferences;
}

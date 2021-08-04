import 'dart:io';
import 'package:args/args.dart';
import 'package:at_cli/at_cli.dart';
import 'package:at_cli/src/command_line_parser.dart';
import 'package:at_cli/src/preference.dart';
import 'package:at_cli/src/config_util.dart';
import 'package:at_utils/at_logger.dart';
import 'package:at_commons/at_commons.dart';

void main(List<String> arguments) async {
  AtSignLogger.root_level = 'severe';
  var logger = AtSignLogger('AtCli');
  try {
    var parsedArgs = CommandLineParser.getParserResults(arguments);
    if (parsedArgs == null || parsedArgs.arguments.isEmpty) {
      print('Usage: \n${CommandLineParser.getUsage()}');
      exit(0);
    }
    var currentAtSign = _getCurrentAtSign(parsedArgs);
    var preferences = _getAtCliPreference(parsedArgs);
    var atCli = AtCli();
    if (preferences.authKeyFile != null) {
      if (!(await File(preferences.authKeyFile).exists())) {
        print('Given Authentication key file is not exists. '
            '\nPlease update correct file path in config or provide as commandline argument');
        print('Usage: \n ${CommandLineParser.getUsage()}');
        exit(0);
      }
    }
    atCli.init(currentAtSign, preferences);
    var result;
    // If a verb is provided, call execute method with arguments
    // Else if command is provided as argument, we'll execute command directly.
    if (parsedArgs['verb'] != null) {
      result = await atCli.execute(parsedArgs);
    } else if (parsedArgs['command'] != null) {
      var command = parsedArgs['command'];
      var auth = parsedArgs['auth'];
      result = await atCli.executeCommand(command, isAuth: auth == 'true');
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
  return (arguments != null)
      ? ((arguments['atsign'] != null)
          ? arguments['atsign']
          : ConfigUtil.getYaml()!['auth']['at_sign'])
      : ConfigUtil.getYaml()!['auth']['at_sign'];
}

String getCommand(ArgResults arguments) {
  print(arguments);
  return arguments.toString();
}

AtCliPreference _getAtCliPreference(ArgResults? parsedArgs) {
  var rootDomainFromConfig = ConfigUtil.getYaml()!['root_server']['host'];
  var preferences = AtCliPreference();
  if (rootDomainFromConfig != null) {
    preferences.rootDomain = rootDomainFromConfig;
  }

  if (parsedArgs != null) {
    if (parsedArgs['auth'] != null) {
      preferences.authRequired = (parsedArgs['auth'] == 'true');
    } else if (ConfigUtil.getYaml() != null &&
        ConfigUtil.getYaml()!['auth'] != null &&
        ConfigUtil.getYaml()!['auth']['required'] != null) {
      preferences.authRequired = ConfigUtil.getYaml()!['auth']['required'];
    }
  } else if (ConfigUtil.getYaml() != null &&
      ConfigUtil.getYaml()!['auth'] != null &&
      ConfigUtil.getYaml()!['auth']['required'] != null) {
    preferences.authRequired = ConfigUtil.getYaml()!['auth']['required'];
  }

  preferences.authMode = (parsedArgs != null)
      ? ((parsedArgs['mode'] != null)
          ? parsedArgs['mode']
          : ConfigUtil.getYaml()!['auth']['mode'])
      : ConfigUtil.getYaml()!['auth']['mode'];

  preferences.authKeyFile = (parsedArgs != null)
      ? ((parsedArgs['authKeyFile'] != null)
          ? parsedArgs['authKeyFile']
          : ConfigUtil.getYaml()!['auth']['key_file_location'])
      : ConfigUtil.getYaml()!['auth']['key_file_location'];
  return preferences;
}

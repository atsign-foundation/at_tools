import 'dart:io';
import 'package:args/args.dart';
import 'package:at_cli/at_cli.dart';
import 'package:at_cli/src/command_line_parser.dart';
import 'package:at_cli/src/preference.dart';
import 'package:at_cli/src/config_util.dart';

void main(List<String> arguments) async {
  var currentAtSign = ConfigUtil.getYaml()['auth']['at_sign'];
  var rootDomainFromConfig = ConfigUtil.getYaml()['root_server']['host'];
  var preferences = AtCliPreference();
  if (rootDomainFromConfig != null) {
    preferences.rootDomain = rootDomainFromConfig;
  }
  preferences.authMode = ConfigUtil.getYaml()['auth']['mode'];
  preferences.authKeyFile = ConfigUtil.getYaml()['auth']['key_file_location'];
  var parsedArgs = CommandLineParser.getParserResults(arguments);
  var atCli = AtCli();
  await atCli.init(currentAtSign, preferences);
  var result;
  if (parsedArgs['verb'] != null) {
    result = await atCli.execute(parsedArgs);
  } else if (parsedArgs['command'] != null) {
    var command = parsedArgs['command'];
    var auth = parsedArgs['auth'];
    result = await atCli.executeCommand(command, isAuth: auth == 'true');
  } else {
    print('Invalid command. Verb or command not entered');
  }
  print(result);
  exit(0);
}

String getCommand(ArgResults arguments) {
  print(arguments);
  return arguments.toString();
}

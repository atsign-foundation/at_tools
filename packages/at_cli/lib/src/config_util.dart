import 'dart:io';

import 'package:at_utils/at_utils.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

class ConfigUtil {
  static late final ApplicationConfiguration appConfig;

  static Future<void> init() async {
    String configPath = await _getConfigFile();
    appConfig = ApplicationConfiguration(configPath);
  }

  static YamlMap? getYaml() {
    return appConfig.getYaml();
  }

  static Future<String> _getConfigFile() async {
    // Generate the path to the config file which will exist at:
    // ~/.atsign/at_cli/config.yaml
    String? filePath = getHomeDirectory();
    if (filePath == null) {
      throw Exception('Unable to resolve the home directory.');
    }
    filePath = '$filePath/.atsign/at_cli/config.yaml';

    // If the config file doesn't exist, generate a default one.
    if (!await File(filePath).exists()) {
      await _generateConfigFile(filePath);
    }

    return filePath;
  }

  static Future<void> _generateConfigFile(String path) async {
    File f = File(path);

    await f.create(recursive: true);
    await f.writeAsString(defaultConfigYaml);
  }

  // Get the home directory or null if unknown.
  // From atsign-foundation/at_talk
  static String? getHomeDirectory() {
    switch (Platform.operatingSystem) {
      case 'linux':
      case 'macos':
        return Platform.environment['HOME'];
      case 'windows':
        return Platform.environment['USERPROFILE'];
      case 'android':
        // Probably want internal storage.
        return '/storage/sdcard0';
      case 'ios':
        // iOS doesn't really have a home directory.
        return null;
      case 'fuchsia':
        // I have no idea.
        return null;
      default:
        return null;
    }
  }
}

String defaultConfigYaml = YAMLWriter().write(
  {
    'root_server': {
      'port': 64,
      'host': 'root.atsign.org',
    },
    'log': {
      'debug': false,
    },
    'auth': {
      'required': true,
      'mode': 'pkam',
      'key_file_location': '~/.atsign/keys/@alice.atKeys',
      'at_sign': '@alice',
    },
  },
);

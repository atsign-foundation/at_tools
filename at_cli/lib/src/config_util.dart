import 'dart:io';
import 'dart:isolate';

import 'package:at_utils/at_utils.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

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
    var fileUri = await Isolate.resolvePackageUri(
        Uri.parse('package:at_cli/'));
    if (fileUri == null) {
      throw Exception('Could not find package location');
    }
    Directory packageRoot = Directory.fromUri(fileUri).parent;
    return path.join(packageRoot.path, 'config/config.yaml');
  }
}

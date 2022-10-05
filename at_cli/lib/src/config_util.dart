import 'dart:io';

import 'package:at_utils/at_utils.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

class ConfigUtil {
  static final ApplicationConfiguration appConfig =
      ApplicationConfiguration(_getConfigDirectory());

  static YamlMap? getYaml() {
    return appConfig.getYaml();
  }

  static String _getConfigDirectory() {
    if (!File('config/config.yaml').existsSync()) {
      return path.join(Directory.current.parent.path, 'config/config.yaml');
    }
    return path.join(Directory.current.path, 'config/config.yaml');
  }
}
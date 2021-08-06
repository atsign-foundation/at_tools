import 'package:yaml/yaml.dart';
import 'dart:io';

/// Application Configuration class
class ApplicationConfiguration {
  YamlMap? _yamlMap;

  /// Constructor with a String parameter [configPath].
  ApplicationConfiguration(String configPath) {
    if (File(configPath).existsSync()) {
      _yamlMap = loadYaml(File(configPath).readAsStringSync());
    }
  }

  /// Returns a [_yamlMap] value from the configuration.
  YamlMap? getYaml() {
    return _yamlMap;
  }
}

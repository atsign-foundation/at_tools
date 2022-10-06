import 'dart:io';

import 'package:at_utils/at_utils.dart';
import 'package:sshnp_register_tool/colors.dart';

class IOUtil {
  /// Print 'c' client options
  static void printClientUsage() {
    print('${Colors.white.code}Choose an option:');
    print('1. I need a free atSign');
    print('2. I have an unactivated atSign');
  }

  /// Print 'd' device options
  static void printDeviceUsage() {
    print('${Colors.white.code}Choose an option:');
    print('1. I need a free atSign');
    print('2. I have an unactivated atSign');
    print(
        '3. Setup sshnpd.service (automatically run sshnpd (daemon) when device boots');
  }

  /// Print a list of given atSigns
  /// Example:
  /// [0]: @atSign1
  /// [1]: @atSign2
  /// [2]: @atSign3
  static void printAtSigns(List<String> atSigns) {
    for (int i = 0; i < atSigns.length; i++) {
      print('[${i + 1}]: @${atSigns[i]}');
    }
  }

  /// Format an atSign String to be proper (with '@')
  static String formatAtSign(String atSign) {
    return AtUtils.fixAtSign(AtUtils.formatAtSign(atSign)!);
  }

  /// Returns the user input string read from terminal.
  /// If data is returned without a line terminator, return null if no bytes preceded the end of input.
  /// Setting prompt = false will not print "Enter choice:" before asking for a prompt, so you must handle your own prompt.
  /// Makes the prompt and choice red colored in the terminal, then defaults back to white
  static String getChoice({prompt = true}) {
    if (prompt) print('${Colors.magenta.code}Enter choice:');
    String input = (stdin.readLineSync() ?? '').toLowerCase();
    print(Colors.reset.code);
    return input;
  }

  /// creates directories if doesn't exist already
  /// example path: /home/atsign/.sshnp
  static Future<void> createDir(String path) async {
    Directory dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// returns ~/.atsign/keys/ directory path based on OS
  static String getUriDirectoryPath() {
    String home = "";
    if (Platform.isMacOS) {
      home = Platform.environment['HOME']!;
    } else if (Platform.isLinux) {
      home = Platform.environment['HOME']!;
    } else if (Platform.isWindows) {
      home = Platform.environment['UserProfile']!;
    }
    final String path = "$home/.atsign/keys/";
    return path;
  }
}

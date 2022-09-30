import 'dart:io';

import 'package:sshnp_register_tool/io_util.dart';

/// This class helps write the `sshnpd.service` file in the `~/etc/systemd/system/` path
class SystemdUtil {
  /// Read sshnpd.service as a string
  static Future<String> readSshnpdService() async{
    final Uri uri = Uri.file('${Platform.script.path}/../.././lib/sshnpd.service');
    final File file = File.fromUri(uri);
    final String read = await file.readAsString();
    return read;
  }

  static Future<void> writeSshnpdService() async {
    String systemdServiceScript = await readSshnpdService();

    final Uri uriDirectory = Uri.directory(
        '${Platform.environment['HOME']}/etc/systemd/system/',
        windows: Platform.isWindows);
    final String directoryPath = uriDirectory.toFilePath();
    await IOUtil.createDir(directoryPath);
    final File file = File('${directoryPath}sshnpd.service');
    await file.writeAsString(systemdServiceScript);
  }
}

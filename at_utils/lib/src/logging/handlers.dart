import 'dart:io';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

/// Handler class for AtSignLogger
abstract class LoggingHandler {
  /// Can extend LogRecord if any atsign specific field has to be logged.
  void call(LogRecord record);
}

/// Designing the log statement to print in Debug console / Debug terminal
class ConsoleLoggingHandler implements LoggingHandler {
  String? iconInfo;
  @override
  void call(LogRecord record) {
    switch (record.level.name.toLowerCase()) {
      case 'info':
        iconInfo = '💡 [INFO]';
        break;
      case 'severe':
        iconInfo = '💥 [SEVERE]';
        break;
      case 'shout':
        iconInfo = '🔫 [SHOUT]';
        break;
      case 'warning':
        iconInfo = '❓ [WARNING]';
        break;
      case 'finer':
        iconInfo = '💬 [FINER]';
        break;
      case 'finest':
        iconInfo = '💬 [FINEST]';
        break;
      default:
        iconInfo = '💬 [ALL]';
        break;
    }
    print(
        '$iconInfo | ${DateFormat().format(record.time)} | ${record.loggerName} | ${record.message} \n');
  }
}

/// Log in to a file.
class FileLoggingHandler implements LoggingHandler {
  late File _file;
  String? iconInfo;
  FileLoggingHandler(String filename) {
    _file = File(filename);
  }
  @override
  void call(LogRecord record) {
    switch (record.level.name.toLowerCase()) {
      case 'info':
        iconInfo = '💡 [INFO]';
        break;
      case 'severe':
        iconInfo = '💥 [SEVERE]';
        break;
      case 'shout':
        iconInfo = '🔫 [SHOUT]';
        break;
      case 'warning':
        iconInfo = '❓ [WARNING]';
        break;
      case 'finer':
        iconInfo = '💬 [FINER]';
        break;
      case 'finest':
        iconInfo = '💬 [FINEST]';
        break;
      default:
        iconInfo = '💬 [ALL]';
        break;
    }
    var f = _file.openSync(mode: FileMode.append);
    f.writeStringSync(
        '$iconInfo | ${DateFormat().format(record.time)} | ${record.loggerName} | ${record.message} \n');
    f.closeSync();
  }
}

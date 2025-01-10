import 'dart:io';

import 'package:sync/mutex.dart';

class Serial {
  static IOSink loggingSink = stderr;
  static IOSink promptSink = stdout;

  static void log(String line) {
    loggingSink.writeln(line);
  }

  static final Mutex _stdinMutex = Mutex();
  static Future<String?> blockForInput(String prompt) async {
    await _stdinMutex.acquire();
    promptSink.writeln(prompt);
    var res = stdin.readLineSync();
    _stdinMutex.release();
    return res;
  }
}

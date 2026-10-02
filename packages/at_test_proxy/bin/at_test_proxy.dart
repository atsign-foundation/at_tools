import 'dart:io';

import 'package:at_test_proxy/src/args.dart';
import 'package:at_test_proxy/src/runner.dart';

void main(List<String> argv) async {
  final Args args;
  try {
    args = parseArgs(argv);
  } catch (_) {
    exit(1);
  }
  if (args.useTLS) {
    await startTlsServer(args);
  } else {
    await startTcpServer(args);
  }
}

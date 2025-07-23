import 'dart:async';
import 'dart:io';
import 'package:at_repl/repl.dart';
import 'package:at_utils/at_utils.dart';
import 'package:io/ansi.dart';
import 'package:args/args.dart';
Future<void> main(List<String> args) async {

  // ArgParser, look for -a <atSign>, and --rootUrl <rootUrl> defaults to root.atsign.org:64, and --verbose or -v for verbose output
  final parser = ArgParser()
    ..addOption('atSign', abbr: 'a', mandatory: true, help: 'The atSign to use')
    ..addOption('rootUrl', defaultsTo: 'root.atsign.org:64', help: 'The root URL to connect to')
    ..addOption('keys-file', abbr: 'k', help: 'Path to the atKeys file')
    ..addFlag('verbose', abbr: 'v', defaultsTo: false, help: 'Enable verbose output');

  final results = parser.parse(args);

  final String atSign = results['atSign'] as String;
  String rootUrl = results['rootUrl'] as String;
  final String? keysFile = results['keys-file'] as String?;
  final bool verbose = results['verbose'] as bool;

  if (!rootUrl.contains(':')) {
    rootUrl = '$rootUrl:64';
  }

  String rootDomain = rootUrl.split(':')[0];
  int rootPort = int.parse(rootUrl.split(':')[1]);

  AtSignLogger.root_level = verbose ? 'info' : 'shout';

  REPL repl = REPL();
  repl.outputStream.writeln(blue.wrap("Starting at_repl with atSign: $atSign ($rootDomain:$rootPort) ..."));
  bool success = await repl.authenticate(rootDomain: rootDomain, rootPort: rootPort, atSign: atSign, keysFile: keysFile);
  repl.start();
}


import 'dart:async';
import 'dart:io';
import 'package:at_repl/repl.dart';
import 'package:at_utils/at_utils.dart';
import 'package:io/ansi.dart';
import 'package:args/args.dart';

Future<void> main(List<String> args) async {
  // ArgParser, look for -a <atSign>, and --root-domain (<host>[:port]) defaults to root.atsign.org:64, and --verbose or -v for verbose output
  final parser = ArgParser()
    ..addOption('atSign',
        abbr: 'a', help: 'The atSign to use', mandatory: true)
    ..addOption('root-domain',
        defaultsTo: 'root.atsign.org:64',
        help: 'The root domain (optionally host:port) to connect to')
    ..addOption('keys',
        abbr: 'k',
        help: 'Directory that contains the .atKeys file',
        valueHelp: 'path')
    ..addOption('keys-file',
        help: 'Path to the .atKeys file (deprecated, use --keys)', hide: true)
    ..addFlag('verbose',
        abbr: 'v', defaultsTo: false, help: 'Enable verbose output')
    ..addFlag('help',
        abbr: 'h', defaultsTo: false, help: 'Show this help message')
    ..addFlag('version',
        abbr: 'V', defaultsTo: false, help: 'Show at_repl version');

  if (args.contains('--version') || args.contains('-V')) {
    _printVersion();
    return;
  }

  if (args.contains('-h') || args.contains('--help')) {
    _printUsage(parser);
    return;
  }

  late ArgResults results;
  try {
    results = parser.parse(args);
  } catch (e) {
    print('Error: $e');
    print('');
    _printUsage(parser);
    return;
  }

  // Check if required atSign is provided
  final String? atSignArg = results['atSign'] as String?;
  if (atSignArg == null || atSignArg.trim().isEmpty) {
    print('Error: atSign is required');
    print('');
    _printUsage(parser);
    return;
  }
  late final String atSign;
  try {
    atSign = AtUtils.fixAtSign(atSignArg);
  } catch (e) {
    print('Error: $e');
    print('');
    _printUsage(parser);
    return;
  }
  String rootUrl = results['root-domain'] as String;
  final String? keysPath = results.wasParsed('keys')
      ? results['keys'] as String?
      : results['keys-file'] as String?;
  final bool verbose = results['verbose'] as bool;

  if (!rootUrl.contains(':')) {
    rootUrl = '$rootUrl:64';
  }

  String rootDomain = rootUrl.split(':')[0];
  int rootPort = int.parse(rootUrl.split(':')[1]);

  AtSignLogger.root_level = verbose ? 'info' : 'shout';

  REPL repl = REPL();
  repl.outputStream.writeln(blue.wrap(
      "Starting at_repl with atSign: $atSign ($rootDomain:$rootPort) ..."));
  await repl.authenticate(
      rootDomain: rootDomain,
      rootPort: rootPort,
      atSign: atSign,
      keysPath: keysPath);
  repl.start();
}

void _printUsage(ArgParser parser) {
  print('Usage: at_repl [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Use --version or -V to print the current version.');
}

void _printVersion() {
  final version = _readVersion() ?? 'unknown';
  print('at_repl version: $version');
}

String? _readVersion() {
  try {
    final pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync()) {
      return null;
    }
    for (final line in pubspec.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('version:')) {
        final parts = trimmed.split(':');
        if (parts.length >= 2) {
          return parts.sublist(1).join(':').trim();
        }
      }
    }
  } catch (_) {
    // Ignore errors and fallback to null
  }
  return null;
}

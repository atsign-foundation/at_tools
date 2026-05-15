import 'dart:async';
import 'dart:io';
import 'package:at_commons/at_commons.dart';
import 'package:at_repl/repl.dart';
import 'package:at_utils/at_utils.dart';
import 'package:io/ansi.dart';
import 'package:args/args.dart';

Future<void> main(List<String> args) async {
  // ArgParser, look for -a <atSign>, and --root-domain (<host>[:port]) defaults to root.atsign.org:64, and --verbose or -v for verbose output
  final parser = ArgParser()
    ..addOption('atSign',
      abbr: 'a',
      help: 'The atSign to use',
      mandatory: true)
    ..addOption('root-domain',
      defaultsTo: 'root.atsign.org:64',
      help: 'The root domain to connect to. Formats: host, host:port, proxy:host:port',
      aliases: ['rootUrl', 'rootDomain', 'root-url'])
    ..addOption('key-file',
      aliases: ['keys', 'keys-file'],
      help: 'Path to the .atKeys file',
      abbr: 'k')
    ..addFlag('verbose',
      abbr: 'v',
      defaultsTo: false,
      help: 'Enable verbose output')
    ..addFlag('help',
      abbr: 'h',
      defaultsTo: false,
      help: 'Show this help message')
    ..addFlag('version',
      defaultsTo: false,
      help: 'Show at_repl version');

  if (args.contains('--version')) {
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

  final Atsign atSign = (results['atSign'] as Atsign).toAtsign();
  final String rootUrl = results['root-domain'] as String;
  final String? keysPath = results['key-file'] as String?;
  final bool verbose = results['verbose'] as bool;

  late final AtRootDomain rootDomain;
  try {
    rootDomain = AtRootDomain.parse(rootUrl);
  } catch (e) {
    print('Error: invalid root domain "$rootUrl": $e');
    print('');
    _printUsage(parser);
    return;
  }

  AtSignLogger.root_level = verbose ? 'info' : 'shout';

  REPL repl = REPL();
  repl.outputStream.writeln(blue.wrap(
      "Starting at_repl with Atsign: $atSign (${rootDomain.rootDomain}:${rootDomain.rootPort}) ..."));
  await repl.authenticate(
      rootDomain: rootDomain,
      atSign: atSign,
      keysPath: keysPath);
  repl.start();
}

void _printUsage(ArgParser parser) {
  print('Usage: at_repl [options]');
  print('');
  print('Options:');
  print(parser.usage);
}

void _printVersion() {
  final version = _readVersion() ?? 'unknown';
  print(version);
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

import 'package:args/args.dart';

/// A class for taking a list of raw command line arguments and parsing out
/// options and flags from them.
class CommandLineParser {
  /// Parses [arguments], a list of command-line arguments, matches them against the
  /// flags and options defined by this parser, and returns the result.
  static var parser = ArgParser();
  static ArgResults? getParserResults(List<String> arguments) {
    var results;
    // var parser = ArgParser();
    parser.addFlag('auth',
        help: 'Set this flag if command needs auth to server',
        abbr: 'a',
        defaultsTo: false);
    // parser.addOption('auth',
    //     abbr: 'a', help: 'Set this flag if command needs auth to server');
    parser.addOption('mode',
        allowed: ['cram', 'pkam'],
        abbr: 'm',
        help: 'Choose Authentication mode if auth required',
        defaultsTo: 'pkam');
    parser.addOption('authKeyFile', abbr: 'f', help: 'cram/pkam file path');
    parser.addOption('atsign', help: 'Current Atsign');
    parser.addOption('command', abbr: 'c', help: 'The at command to execute');
    parser.addOption('verb', abbr: 'v', help: 'The verb to execute');
    // parser.addOption('public',
    //     abbr: 'p', help: 'set to true if key has public access');
    parser.addFlag('public',
        abbr: 'p',
        help: 'set to true if key has public access',
        defaultsTo: false);
    parser.addOption('key', abbr: 'k', help: 'key to update');
    parser.addOption('value', help: 'value of the key');
    parser.addOption('shared_with',
        abbr: 'w', help: 'atsign to whom key is shared');
    parser.addOption('shared_by', abbr: 'b', help: 'atsign who shared the key');
    parser.addOption('regex', abbr: 'r', help: 'regex for scan');

    try {
      if (arguments != null && arguments.isNotEmpty) {
        results = parser.parse(arguments);
      }
      return results;
    } on ArgParserException {
      throw ArgParserException('ArgParserException\n' + parser.usage);
    }
  }

  static String getUsage() {
    return parser.usage;
  }
}

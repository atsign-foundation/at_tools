import 'package:args/args.dart';

/// A class for taking a list of raw command line arguments and parsing out
/// options and flags from them.
class CommandLineParser {
  /// Parses [arguments], a list of command-line arguments, matches them against the
  /// flags and options defined by this parser, and returns the result.
  var parser;

  ArgResults getParserResults(List<String> arguments) {
    var results;
    parser = ArgParser();
    parser.addOption('file_path',
        abbr: 'p', help: '.keys or .zip file path which contains keys');
    parser.addOption('from_response', abbr: 'r', help: 'from:@atSign response');

    try {
      if (arguments != null && arguments.isNotEmpty) {
        results = parser.parse(arguments);
        if (results.options.length != parser.options.length) {
          throw ArgParserException('Invalid Arguments \n' + parser.usage);
        }
      } else {
        throw ArgParserException('ArgParser Exception \n' + parser.usage);
      }
      return results;
    } on ArgParserException {
      throw ArgParserException('ArgParserException\n' + parser.usage);
    }
  }
}

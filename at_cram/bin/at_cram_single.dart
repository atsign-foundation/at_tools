import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:crypto/crypto.dart';

/// command-line usage

/// (1)
/// first compile this file (replace <name> with the name of the file)
/// dart compile exe bin/at_cram_single.dart -o <name>

/// (2)
/// run the compiled file, <cramSecret> comes from initial retrieval of your atSign (in your QR code or web API), <challenge> comes from the `from:@sign` challenge.
/// ./cram -k <cramSecret> -c <challenge>

/// (3)
/// program spits out digest
/// in openssl, you can now do `cram:<digest>`

void main(List<String> arguments) {
  if (arguments.length != 4) {
    _printInstructions();
    return;
  }
  var parser = ArgParser();
  parser.addOption('cramSecret', abbr: 'k', mandatory: true, help: 'CRAM secret initially retrieved upon receiving an atSign.');
  parser.addOption('challenge',
      abbr: 'c', mandatory: true, help: 'The challenge received after doing `from:@myatsign`, you get: `data:<challenge>` where <challenge> is the challenge.');
  var results = parser.parse(arguments);
  var cramSecret = results['cramSecret'];
  var challenge = results['challenge'];
  cramSecret = cramSecret.trim();
  challenge = challenge.trim();
  stdout.write('\ncramSecret: $cramSecret\n');
  stdout.write('challenge: $challenge\n');
  var combo = '$cramSecret$challenge';
  var bytes = utf8.encode(combo);
  var digest = sha512.convert(bytes);
  stdout.write('\n');
  stdout.write('digest: $digest');
  stdout.write('\n');
}

void _printInstructions() {
  stdout.write('\nCRAM digesting in one single line\n');
  stdout.write('  --cramSecret -k \t| cramSecret received when you initially get an @ sign (usually in the form of a QR code)\n');
  stdout.write('  --challenge -c \t| the challenge response you receive after doing `from:@youratsign`, will respond with `data:<challenge>`\n');
  stdout.write('  Example: `dart bin/at_cram_single.dart -k cramSecret123 -c fromChallenge123`\n');
}

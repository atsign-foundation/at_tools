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
  if (arguments.length != 2) {
    print('Invalid usage! CRAM <cramSecret> <from challenge>');
    return;
  }
  var cramSecret = arguments[0];
  var challenge = arguments[1];
  cramSecret = cramSecret.trim();
  challenge = challenge.trim();
  var combo = '$cramSecret$challenge';
  var bytes = utf8.encode(combo);
  var digest = sha512.convert(bytes);
  stdout.write('\n');
  stdout.write(digest);
  stdout.write('\n');
}

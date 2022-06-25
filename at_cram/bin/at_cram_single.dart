import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

// command-line usage

// (1)
// first compile this file (replace <name> with the name of the file)
// dart compile exe bin/at_cram_single.dart -o <name>

// (2)
// run the compiled file
// ./cram <cramSecret> <from: challenge>

// (3)
// program spits out digest
// in openssl, you can now do `cram:<digest>`

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

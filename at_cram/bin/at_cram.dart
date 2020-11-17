import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'dart:convert';

main(List<String> arguments) {
  var Name = arguments[0];
  var secret =  getSecret(Name);
  secret = secret.trim();
  var challenge = stdin.readLineSync();
  challenge = challenge.trim();
  var combo = '${secret}${challenge}';
  var bytes = utf8.encode(combo);
  var digest = sha512.convert(bytes);
  stdout.write(digest);
  stdout.write('\n');
}


String getSecret(String filename)  {

  var pathToFile = join(dirname(Platform.script.toFilePath()), filename);
  var contents =  File(pathToFile).readAsStringSync();
  return(contents);
}

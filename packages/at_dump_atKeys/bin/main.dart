import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:args/args.dart';
import 'package:at_dump_atKeys/commandline_parser.dart';
import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';

var parser = ArgParser();

Future<void> main(List<String> arguments) async {
  try {
    parser = CommandLineParser().getParser();
    if (arguments.length == 1 &&
        (arguments[0] == '-h' || arguments[0] == '--help') ||
        arguments.length ==0) {
      print('Usage: \ndart run bin/main.dart \n${parser.usage}');
      exit(0);
    }
    var args = CommandLineParser().getParserResults(arguments, parser);
    var filePath = args['file_path'];
    var keyMap = new Map();
    var isFileExists = await File(filePath).exists();
    if (!isFileExists) {
      throw Exception('File not found');
    }
    var fileContents = File(filePath).readAsStringSync();
    var keysJSON = json.decode(fileContents);
    var aesEncryptionKey = keysJSON['selfEncryptionKey'];
    keyMap['pkamPublicKey'] =
        RSAPublicKey.fromString(decryptValue(keysJSON['aesPkamPublicKey'], aesEncryptionKey));
    keyMap['pkamPrivateKey'] =
        RSAPrivateKey.fromString(decryptValue(keysJSON['aesPkamPrivateKey'], aesEncryptionKey));
    keyMap['encryptionPublicKey'] =
        RSAPublicKey.fromString(decryptValue(keysJSON['aesEncryptPublicKey'], aesEncryptionKey));
    keyMap['encryptionPrivateKey'] =
        RSAPrivateKey.fromString(decryptValue(keysJSON['aesEncryptPrivateKey'], aesEncryptionKey));
    keyMap['selfEncryptionKey'] = aesEncryptionKey;
    keyMap.forEach((k, v) => print("$k: $v\n"));
  } on ArgParserException catch (e) {
    print('$e');
  } on Exception catch (e) {
    print('Exception : $e');
  }
}

String decryptValue(String encryptedValue, String decryptionKey) {
  var aesKey = AES(Key.fromBase64(decryptionKey));
  var decrypter = Encrypter(aesKey);
  var iv2 = IV.fromLength(16);
  return decrypter.decrypt64(encryptedValue, iv: iv2);
}

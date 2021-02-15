import 'dart:convert';
import 'package:at_pkam/commandline_parser.dart';
import 'package:encrypt/encrypt.dart';
import 'package:crypton/crypton.dart';
import 'dart:io';
import 'package:at_pkam/pkam_constants.dart';
import 'package:archive/archive_io.dart';

Future<void> main(List<String> arguments) async {
  try {
    var args = CommandLineParser().getParserResults(arguments);
    var filePath = args['file_path'];
    var challenge = args['from_response'];
    var privateKey;
    if (filePath.endsWith(AT_KEYS)) {
      privateKey = await getSecretFromAtKeys(filePath);
    } else if (filePath.endsWith(ZIP)) {
      privateKey = await getSecretFromZip(filePath);
    } else {
      throw Exception('Usage : ${CommandLineParser().getParserResults(null)}');
    }
    privateKey = privateKey.trim();
    var key = RSAPrivateKey.fromString(privateKey);
    challenge = challenge.trim();
    var signature = key.createSignature(challenge);
    stdout.write(signature);
    stdout.write('\n');
  } on Exception catch (e) {
    print('Exception : ${e}');
  }
}

Future<String> getSecretFromAtKeys(String filePath) async {
  try {
    var isFileExists = await File(filePath).exists();
    if (!isFileExists) {
      throw Exception('File not found');
    }
    var fileContents = File(filePath).readAsStringSync();
    var keysJSON = json.decode(fileContents);
    var encryptedPKAMPrivateKey = keysJSON['aesPkamPrivateKey'];
    var aesEncryptionKey = keysJSON['selfEncryptionKey'];
    var pkamPrivateKey =
        decryptValue(encryptedPKAMPrivateKey, aesEncryptionKey);
    return pkamPrivateKey;
  } on Exception catch (e) {
    print('Exception while getting secret : ${e}');
  }
}

Future<String> getSecretFromZip(String filePath) async {
  try {
    var isFileExists = await File(filePath).exists();
    if (!isFileExists) {
      throw Exception('File not found');
    }
    var fileContents;
    var bytes = File(filePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (var file in archive) {
      if (file.name.contains('atKeys')) {
        fileContents = String.fromCharCodes(file.content);
      }
    }
    var keysJSON = json.decode(fileContents);
    var encryptedPKAMPrivateKey = keysJSON['aesPkamPrivateKey'];
    print('Please scan QR code image and provide aesKey');
    var aesKey = stdin.readLineSync();
    aesKey = aesKey.trim();
    var pkamPrivateKey = decryptValue(encryptedPKAMPrivateKey, aesKey);
    return pkamPrivateKey;
  } on Exception catch (e) {
    print('Exception while getting secret : ${e}');
  }
}

String decryptValue(String encryptedValue, String decryptionKey) {
  var aesKey = AES(Key.fromBase64(decryptionKey));
  var decrypter = Encrypter(aesKey);
  var iv2 = IV.fromLength(16);
  return decrypter.decrypt64(encryptedValue, iv: iv2);
}

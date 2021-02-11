import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:crypton/crypton.dart';
import 'dart:io';
import 'package:at_pkam/pkam_constants.dart';

Future<void> main(List<String> arguments) async {
  var filePath = arguments[0];
  var challenge = arguments[1];
  var privateKey;
  if (filePath.endsWith(AT_KEYS)) {
    privateKey = await getSecretFromAtKeys(filePath);
  } else {
    throw Exception('Please provide .keys file as first argument');
  }
  privateKey = privateKey.trim();
  var key = RSAPrivateKey.fromString(privateKey);

  challenge = challenge.trim();
  var signature = key.createSignature(challenge);
  stdout.write(signature);
  stdout.write('\n');
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

String decryptValue(String encryptedValue, String decryptionKey) {
  var aesKey = AES(Key.fromBase64(decryptionKey));
  var decrypter = Encrypter(aesKey);
  var iv2 = IV.fromLength(16);
  return decrypter.decrypt64(encryptedValue, iv: iv2);
}

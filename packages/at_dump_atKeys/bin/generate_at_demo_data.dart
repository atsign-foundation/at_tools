import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:at_dump_atKeys/commandline_parser.dart';
import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';

/// The script accepts the path to the directory that contains ".atKeys" file(s),
/// Iterates through all the ".atKeys" files, decrypts the keys and writes to a file.
///
/// Optionally accepts the following flags:
///   * -o to set the destination directory to create the file. Defaults to the current directory
///   * -f to set the filename. Defaults to at_demo_data.dart
///   * -p This flag indicates to decrypt all keys or only PKAM keys. Defaults to "all"
///        - When set to "all" all the keys are decrypted and written to output file.
///        - Set the flag to "PKAM" to write only PKAM private key to the output file.
///          For the end2end test in at_server, only PKAM keys are needed and for end2end tests
///          in at_client all the keys are needed.
///
/// Usage:
///
///  The following command iterates through all the .atKeys file present in "/home/user" directory and
///  writes the decrypted keys to an output file.
///
/// ```dart
///   dart bin/generate_at_demo_data.dart -d /home/user/atKeys
///```
///
/// With optional flags:
///  The below command places the output file in "/home/user/destDir" and creates a file with name "at_credentials.dart"
/// ```dart
///   dart bin/generate/at_demo_data.dart -d /home/user/atKeys -o /home/user/destDir -f at_credentials.dart
/// ```

Future<void> main(List<String> arguments) async {
  try {
    ArgParser argParser = getArgParser();
    if (arguments.length < 2 ||
        (arguments[0] == '-h' || arguments[0] == '--help') ||
        arguments.isEmpty) {
      print(
          'Usage:\ndart run bin/generate_at_demo_data.dart \n${argParser.usage}');
      exit(0);
    }
    var args = CommandLineParser().getParserResults(arguments, argParser);
    String dirPath = args['directoryPath'];
    String outputDir = args['outputDir'];
    String fileName = args['fileName'];
    String preference = args['preference'].toString().toLowerCase();
    if (!outputDir.endsWith('/')) {
      outputDir = '$outputDir/';
    }
    List<FileSystemEntity> listOfAtKeys = Directory(dirPath).listSync();

    if (listOfAtKeys.isEmpty) {
      print('The directory does not contains atKeys file(s)');
      return;
    }
    // Setting recursive to true, to create non-existent path(s) in the output directory
    var file = await File('$outputDir$fileName').create(recursive: true);
    file.writeAsStringSync('var pkamPrivateKeyMap = ');
    Map responseKeyMap = {};

    await Future.forEach(
        listOfAtKeys,
        (FileSystemEntity filePath) =>
            processAtKeysContent(filePath, file, responseKeyMap, preference));

    file.writeAsStringSync(jsonEncode(responseKeyMap), mode: FileMode.append);
    file.writeAsStringSync(';', mode: FileMode.append);

    print('The $fileName is successfully generated in $outputDir');
  } on ArgParserException catch (e) {
    print('$e');
  } on Exception catch (e) {
    print('Exception : $e');
  }
}

Future<void> processAtKeysContent(FileSystemEntity fileSystemEntity, File file,
    Map decryptedKeysMaps, String preference) async {
  // Ignore files that are other than ".atKeys" files. So return.
  if (!fileSystemEntity.path.toLowerCase().endsWith('.atkeys')) {
    return;
  }

  var filePath = fileSystemEntity.path;
  var atSign = filePath.substring(filePath.lastIndexOf('/') + 1);
  atSign = atSign.replaceFirst('_key.atKeys', '');
  var fileContents = File(filePath).readAsStringSync();
  var keysJSON = json.decode(fileContents);
  var aesEncryptionKey = keysJSON['selfEncryptionKey'];

  switch (preference) {
    case 'all':
      var keyMap = {};
      var aesEncryptionKey = keysJSON['selfEncryptionKey'];
      keyMap['pkamPublicKey'] = RSAPublicKey.fromString(
              decryptValue(keysJSON['aesPkamPublicKey'], aesEncryptionKey))
          .toString();
      keyMap['pkamPrivateKey'] = RSAPrivateKey.fromString(
              decryptValue(keysJSON['aesPkamPrivateKey'], aesEncryptionKey))
          .toString();
      keyMap['encryptionPublicKey'] = RSAPublicKey.fromString(
              decryptValue(keysJSON['aesEncryptPublicKey'], aesEncryptionKey))
          .toString();
      keyMap['encryptionPrivateKey'] = RSAPrivateKey.fromString(
              decryptValue(keysJSON['aesEncryptPrivateKey'], aesEncryptionKey))
          .toString();
      keyMap['selfEncryptionKey'] = aesEncryptionKey;
      decryptedKeysMaps.putIfAbsent(atSign, () => keyMap);
      break;
    case 'pkam':
      var pkamPrivateKey = RSAPrivateKey.fromString(
          decryptValue(keysJSON['aesPkamPrivateKey'], aesEncryptionKey));
      decryptedKeysMaps.putIfAbsent(atSign, () => pkamPrivateKey.toString());
  }
}

ArgParser getArgParser() {
  var argParser = ArgParser()
    ..addOption('directoryPath',
        abbr: 'd', help: 'The directory path which contains atKeys')
    ..addOption('outputDir',
        abbr: 'o',
        help: 'The output directory to place the generated file',
        defaultsTo: Directory.current.path)
    ..addOption('fileName',
        abbr: 'f',
        help: 'The filename to write the pkam private key',
        defaultsTo: 'at_demo_data.dart')
    ..addOption('preference',
        abbr: 'p', help: 'Write all keys or only pkam', defaultsTo: 'all');
  return argParser;
}

String decryptValue(String encryptedValue, String decryptionKey) {
  var aesKey = AES(Key.fromBase64(decryptionKey));
  var decrypter = Encrypter(aesKey);
  var iv2 = IV.fromLength(16);
  return decrypter.decrypt64(encryptedValue, iv: iv2);
}

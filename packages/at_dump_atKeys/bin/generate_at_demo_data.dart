import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:at_dump_atKeys/commandline_parser.dart';
import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';

/// The script accepts the .atKeys file and atSign and writes the decrypted pkam private key of the atSign
/// to a new file
///
/// Usage:
///
/// ```dart
///   dart bin/generate_at_demo_data.dart -p /home/user/@27salty_keynew.atKeys -a @27salty
///```
///
/// Optionally pass
///   * -o to set the destination directory to create the file. Defaults to the current directory
///   * -f to set the filename. Defaults to at_demo_data.dart
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
    var filePath = args['filePath'];
    var atSign = args['atSign'];
    String outputDir = args['outputDir'];
    if (!outputDir.endsWith('/')) {
      outputDir = '$outputDir/';
    }
    String fileName = args['fileName'];
    // Fetch the content from the .atKeys file
    var isFileExists = await File(filePath).exists();
    if (!isFileExists) {
      throw Exception('atKeys file not found in the given filepath');
    }
    var fileContents = File(filePath).readAsStringSync();
    var keysJSON = json.decode(fileContents);

    var aesEncryptionKey = keysJSON['selfEncryptionKey'];
    var pkamPrivateKey = RSAPrivateKey.fromString(
        decryptValue(keysJSON['aesPkamPrivateKey'], aesEncryptionKey));

    var pkamPrivateKeyMap = {atSign: pkamPrivateKey.toString()};
    var encodedString = jsonEncode(pkamPrivateKeyMap);
    // Construct the map. The variable and its key value pair.
    encodedString = 'var pkamPrivateKeyMap = $encodedString;';
    // Write the content to at_demo_data.dart file
    var file = await File('$outputDir$fileName').create();
    file.writeAsStringSync(encodedString);
    print('The $fileName is successfully generated in $outputDir');
  } on ArgParserException catch (e) {
    print('$e');
  } on Exception catch (e) {
    print('Exception : $e');
  }
}

ArgParser getArgParser() {
  var argParser = ArgParser()
    ..addOption('filePath',
        abbr: 'p', help: 'The .atKeys file path which contains keys')
    ..addOption('atSign', abbr: 'a', help: 'atSign')
    ..addOption('outputDir',
        abbr: 'o',
        help: 'The output directory to place the generated file',
        defaultsTo: Directory.current.path)
    ..addOption('fileName',
        abbr: 'f',
        help: 'The filename to write the pkam private key',
        defaultsTo: 'at_demo_data.dart');
  return argParser;
}

String decryptValue(String encryptedValue, String decryptionKey) {
  var aesKey = AES(Key.fromBase64(decryptionKey));
  var decrypter = Encrypter(aesKey);
  var iv2 = IV.fromLength(16);
  return decrypter.decrypt64(encryptedValue, iv: iv2);
}

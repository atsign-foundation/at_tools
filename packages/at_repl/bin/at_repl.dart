import 'dart:convert';

import 'package:args/args.dart';
import 'package:at_client/at_client.dart';
import 'package:at_repl/at_repl.dart' as at_repl;
import 'dart:io';

import 'package:io/ansi.dart';

// REPL <rootUrl> <atSign> <verbose == true|false>
// argparser args
Future<void> main(List<String> arguments) async {
  String rootUrl = "";
  String atSign = "@chess69";
  String secondaryUrl = "";
  bool verbose = false;
  bool enforceNamespace = false;

  final ArgParser argParser = ArgParser()
    ..addOption("atSign", abbr: 'a', mandatory: true)
    ..addOption("rootUrl", abbr: 'r', mandatory: false, defaultsTo: "root.atsign.org:64")
    ..addFlag("verbose", abbr: 'v', defaultsTo: false)
    ..addFlag("enforceNamespace", abbr: 'n', defaultsTo: false);

  if (arguments.isEmpty || arguments.length > 3) {
    stdout.writeln(
        "Usage: REPL <rootUrl: default = 'root.atsign.org:64'> <atSign: required> [<verbose == 'true|false'>]");
  }

  try {
    var results = argParser.parse(arguments);
    rootUrl = results["rootUrl"];
    atSign = results["atSign"];
    verbose = results["verbose"];
    enforceNamespace = results["enforceNamespace"];
    stdout.writeln("Looking up secondary server address for $atSign");
  } catch (e) {
    stdout.writeln(red.wrap("Missing arguments"));
  }

  AtClient? atClient;
  try {
    stdout.writeln(blue.wrap("Connecting..."));
    at_repl.REPL repl = at_repl.REPL(atSign);
    var success = await repl.authenticate();
    atClient = repl.atClient;
    stdout.writeln(green.wrap("Successfully Connected."));
    stdout.writeln(lightGreen.wrap("use /help or help to see available commands"));
  } catch (e) {
    stdout.writeln(red.wrap("disconnected.  $e"));
  }
  // 3. REPL!
  stdout.write(magenta.wrap("$atSign "));
  while (true) {
    // receive a String from stdin
    String? command = stdin.readLineSync(encoding: utf8);
    if (command != null) {
      command = command.trim();
      if (command == "help" || command.startsWith("_") || command.startsWith("/") || command.startsWith("\\")) {
        if (command != "help") {
          command = command.substring(1);
        }
        var args = command.split(" ");
        String verb = args[0];
        if (atClient == null) break;
        switch (verb) {
          case "help":
            printHelpInstructions();
            break;
          case "scan":
            String regex = (args.length > 1 ? args[1] : "");
            var values = await atClient.getAtKeys(regex: regex);
            stdout.writeln(lightCyan.wrap(" => $values"));
            break;
          case "get":
            String key = args[1];
            KeyType type = AtKey.getKeyType(key);
            String? name;
            String atSign = key.substring(key.indexOf('@'));
            String namespace = '';
            if (enforceNamespace) {
              name = key.substring(0, key.indexOf('.'));
              namespace = key.substring(key.indexOf('.') + 1, key.indexOf('@'));
            } else {
              name = key.substring(0, key.indexOf('@'));
            }
            switch (type) {
              case KeyType.selfKey:
                AtKey selfKey = AtKey.self(name, namespace: namespace, sharedBy: atSign).build();
                AtValue atValue = await atClient.get(selfKey);
                stdout.writeln(lightCyan.wrap(" => ${atValue.value}"));
                break;
              case KeyType.sharedKey:
                AtKey sharedKey = AtKey.shared(name, namespace: namespace, sharedBy: atSign).build();
                AtValue atValue = await atClient.get(sharedKey);
                stdout.writeln(lightCyan.wrap(" => ${atValue.value}"));
                break;
              case KeyType.publicKey:
                AtKey publicKey = AtKey.public(name, namespace: namespace, sharedBy: atSign).build();
                AtValue atValue = await atClient.get(publicKey);
                stdout.writeln(lightCyan.wrap(" => ${atValue.value}"));
                break;
              case KeyType.privateKey:
                AtKey privateKey = AtKey.private(name, namespace: namespace).build();
                AtValue atValue = await atClient.get(privateKey);
                stdout.writeln(lightCyan.wrap(" => ${atValue.value}"));
                break;
              case KeyType.invalidKey:
                stdout.writeln(lightCyan.wrap(" => make it properly please"));
                break;
              default:
                stdout.writeln(lightCyan.wrap(" => i don't do funny key types ($type)"));
            }
            break;
          case "put":
            String key = args[1];
            KeyType type = AtKey.getKeyType(key);
            String value = args[2];
            String? name;
            String atSign = key.substring(key.indexOf('@'));
            String namespace = '';
            if (enforceNamespace) {
              name = key.substring(0, key.indexOf('.'));
              namespace = key.substring(key.indexOf('.') + 1, key.indexOf('@'));
            } else {
              name = key.substring(0, key.indexOf('@'));
            }

            stdout.writeln("Type: $type \nValue: $value \nKeyName: $key\nName: $name\n NameSpace: $namespace");
            switch (type) {
              case KeyType.selfKey:
                AtKey selfKey = AtKey.self(name, namespace: namespace, sharedBy: atSign).build();
                bool data = await atClient.put(selfKey, value);
                stdout.writeln(lightCyan.wrap(" => $data"));
                break;
              case KeyType.sharedKey:
                AtKey sharedKey = AtKey.shared(name, namespace: namespace, sharedBy: atSign).build();
                bool data = await atClient.put(sharedKey, value);
                stdout.writeln(lightCyan.wrap(" => $data"));
                break;
              case KeyType.publicKey:
                AtKey publicKey = AtKey.public(name, namespace: namespace, sharedBy: atSign).build();
                bool data = await atClient.put(publicKey, value);
                stdout.writeln(lightCyan.wrap(" => $data"));
                break;
              case KeyType.privateKey:
                AtKey privateKey = AtKey.private(name, namespace: namespace).build();
                bool data = await atClient.put(privateKey, value);
                stdout.writeln(lightCyan.wrap(" => key creation result = $data"));
                break;
              case KeyType.invalidKey:
                stdout.writeln(lightCyan.wrap(" => make it properly please"));
                break;
              default:
                stdout.writeln(lightCyan.wrap(" => i don't do funny key types ($type)"));
            }
            break;
          case "q":
            exit(0);
          case "quit":
            exit(0);
        }
      }
      stdout.write(magenta.wrap("$atSign "));
    }
    // run the command in AtClient
  }
}

void printHelpInstructions() {
  stdout.writeln(lightRed.wrap("\n AtClient REPL"));
  stdout.writeln("Notes:");
  stdout.writeln(
      "    1) By default, REPL treats input as atProtocol commands. Use / for additional commands listed below");

  stdout.write("    2) In the usage examples below, it is assumed that the atSign being used is ");
  stdout.writeln(green.wrap("@alice \n"));
  stdout.write(magenta.wrap(" help or /help"));
  stdout.writeln("- print this help message \n");

  stdout.write(magenta.wrap("/scan"));
  stdout.write(green.wrap(" [regex] "));
  stdout.writeln("- scan for all records, or all records whose keyNames match the regex (e.g. _scan test@alice.*) \n");

  stdout.write(magenta.wrap("/put"));
  stdout.write(green.wrap(" <atKeyName> "));
  stdout.write(lightBlue.wrap(" <value> "));
  stdout.writeln("- create or update a record with the given atKeyName and with the supplied value \n  For example: ");

  stdout.write(magenta.wrap("   /put"));
  stdout.write(green.wrap(" test@alice "));
  stdout.write(lightBlue.wrap(" secrets  "));
  stdout.writeln("->  will create or update a 'self' record (a record private just to @alice)");

  stdout.write(magenta.wrap("   /put"));
  stdout.write(green.wrap(" @bob:test@alice "));
  stdout.write(lightBlue.wrap(" Hello, Bob!  "));
  stdout.writeln("->  will create or update a record encrypted for, and then shared with, @bob \n");

  stdout.write(magenta.wrap("/get"));
  stdout.write(green.wrap(" <atKeyName> "));
  stdout.writeln("- retrieve a value from the record with this atKeyName \n For example: ");

  stdout.write(magenta.wrap("   /get"));
  stdout.write(green.wrap(" test@alice "));
  stdout.writeln("- retrieve a value from test@alice. \n");

  stdout.write(magenta.wrap("/delete"));
  stdout.write(green.wrap(" <atKeyName> "));
  stdout.writeln("- delete the record with this atKeyName (e.g. /delete test@alice) \n");

  stdout.write(magenta.wrap("/q or /quit"));
  stdout.writeln("- will quit the REPL \n");

  stdout.write(red.wrap("NOTE: "));
  stdout.write(magenta.wrap(" /put, /get, and /bold"));
  stdout.writeln("->  will append the current atSign to the atKeyName if not supplied \n");
}

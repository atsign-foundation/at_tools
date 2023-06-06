import 'dart:convert';
import 'package:at_utils/at_logger.dart';
import 'package:args/args.dart';
import 'package:at_client/at_client.dart';
import 'package:at_repl/src/at_repl.dart' as at_repl;
import 'dart:io';
import 'package:io/ansi.dart';

//make sure you cd to at_repl dir.
//cd packages\at_repl

// REPL ONLY REQUIRES AN ATSIGN OPTION
//EX.
//dart run at_repl -a @xavierlin0

//FULL REPL COMMAND
//dart run at_repl -a @xavierlin -r root.atsign.org:64 -v -n

Future<void> main(List<String> arguments) async {
  AtClient? atClient;
  String rootUrl = "";
  String atSign = "@chess69";
  bool verbose = false;
  bool enforceNamespace = false;

  final ArgParser argParser = ArgParser()
    ..addOption("atSign", abbr: 'a', mandatory: true)
    ..addOption("rootUrl", abbr: 'r', mandatory: false, defaultsTo: "root.atsign.org:64")
    ..addFlag("verbose", abbr: 'v', defaultsTo: false)
    ..addFlag("enforceNamespace", abbr: 'n', defaultsTo: false);

  try {
    var results = argParser.parse(arguments);
    rootUrl = results["rootUrl"];
    atSign = results["atSign"];
    verbose = results["verbose"];
    enforceNamespace = results["enforceNamespace"];
    stdout.writeln("Looking up secondary server address for $atSign on $rootUrl");
  } catch (e) {
    stdout.writeln(red.wrap('Invalid arguments. Usage:\n${argParser.usage}'));
    exit(1);
  }

  //Define logger and REPL.
  AtSignLogger.root_level = verbose ? 'info' : 'warning';
  at_repl.REPL repl = at_repl.REPL(atSign, rootUrl: rootUrl);

  //Try to authenticate using the inputted atsigns keys.
  //Keys are usually located in C:\Users\{user}\.atsign\keys
  //or home directory\.atsign\keys
  try {
    stdout.write(blue.wrap("Connecting...   "));
    var success = await repl.authenticate();
    atClient = repl.atClient;
    if (!await atClient.syncService.isInSync()) {
      await repl.syncSecondary();
    }

    if (success) {
      stdout.writeln(green.wrap("Connected."));
    } else {
      stdout.writeln(red.wrap("Failed to authenticate"));
    }

    atClient = repl.atClient;
    stdout.writeln(lightGreen.wrap("use /help or help to see available commands"));
  } catch (e) {
    stdout.writeln(red.wrap('Authentication failed: $e'));
  }

  if (atClient == null) {
    stdout.writeln(red.wrap("Disconnected, atClient is null."));
  }
  var namespaceMsg = (enforceNamespace
      ? "You are enforcing namespaces, be sure to include them"
      : "You don't need to include name spaces.");
  stdout.writeln(yellow.wrap(namespaceMsg));

  // 3. REPL!

  stdout.write(magenta.wrap("$atSign "));

  var lines = stdin.transform(utf8.decoder).transform(const LineSplitter());
  await for (String command in lines) {
    // receive a String from stdin
    try {
      if (command.isNotEmpty) {
        command = command.trim();
        if (command == "help" || command.startsWith("_") || command.startsWith("/") || command.startsWith("\\")) {
          if (command != "help") {
            command = command.substring(1);
          }
          var args = command.split(" ");
          String verb = args[0];
          switch (verb) {
            case "help":
              printHelpInstructions();
              break;
            case "scan":
              String regex = (args.length > 1 ? args[1] : "");
              var values = await atClient!.getAtKeys(regex: regex);
              stdout.writeln(lightCyan.wrap(" => $values"));
              break;
            case "get":
              try {
                var response = await repl.getKey(args, enforceNamespace);
                stdout.writeln(lightCyan.wrap(response));
              } catch (e) {
                stdout.writeln(red.wrap(e.toString()));
              }
              break;
            case "put":
              try {
                var response = await repl.put(args, enforceNamespace);
                stdout.writeln(lightCyan.wrap(response));
              } catch (e) {
                stdout.writeln(red.wrap(e.toString()));
              }
              break;
            case "delete":
              try {
                var response = await repl.delete(args, enforceNamespace);
                stdout.writeln(lightCyan.wrap(response));
              } catch (e) {
                stdout.writeln(red.wrap(e.toString()));
              }
              break;
            case "q":
              exit(0);
            case "quit":
              exit(0);
          }
        } else {
          // run protocol verbs
          try {
            var response = await repl.executeCommand('$command\n');
            stdout.writeln(cyan.wrap("=> $response"));
          } on AtException catch (e) {
            stdout.writeln("atException: ${red.wrap(e.toString())}");
          } on IOException catch (e) {
            stdout.writeln(red.wrap(e.toString()));
          }
        }
      }
      stdout.write(magenta.wrap("$atSign "));
    } on RangeError catch (e) {
      if (!command.contains(".")) {
        stdout.writeln(red.wrap(e.toString()));
      } else {
        stdout.writeln(red.wrap("You are missing the atsign"));
      }
      stdout.write(magenta.wrap("$atSign "));
    }
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
}

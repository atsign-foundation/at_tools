import 'dart:convert';

import 'package:args/args.dart';
import 'package:at_client/at_client.dart';
import 'package:at_repl/at_repl.dart' as at_repl;
import 'dart:io';

import 'package:at_onboarding_cli/at_onboarding_cli.dart';
import 'package:io/ansi.dart';

// REPL <rootUrl> <atSign> <verbose == true|false>
// argparser args
Future<void> main(List<String> arguments) async {
  String rootUrl = "";
  String atSign = "@chess69";
  String secondaryUrl = "";
  bool verbose = false;

  final ArgParser argParser = ArgParser()
    ..addOption("atSign", abbr: 'a', mandatory: true)
    ..addOption("rootUrl", abbr: 'r', mandatory: false, defaultsTo: "root.atsign.org:64")
    ..addFlag("verbose", abbr: 'v', defaultsTo: false);

  if (arguments.isEmpty || arguments.length > 3) {
    stdout.writeln(
        "Usage: REPL <rootUrl: default = 'root.atsign.org:64'> <atSign: required> [<verbose == 'true|false'>]");
  }

  try {
    var results = argParser.parse(arguments);
    rootUrl = results["rootUrl"];
    atSign = results["atSign"];
    verbose = results["verbose"];
    stdout.writeln("Looking up secondary server address for $atSign");
  } catch (e) {
    stdout.writeln(red.wrap("Missing arguments"));
  }

  // 1. onboard
  final AtOnboardingPreference pref = AtOnboardingPreference();

  // 2. create atClient
  RemoteSecondary remoteSecondary = RemoteSecondary(atSign, pref);
  AtClient? atClient;
  try {
    stdout.writeln(blue.wrap("Connecting..."));
    atClient = await AtClientImpl.create(atSign, "soccer0", pref, remoteSecondary: remoteSecondary);
    at_repl.REPL repl = at_repl.REPL(atSign);
    var success = await repl.authenticate();
    stdout.writeln(green.wrap("Successfully Connected."));
    stdout.writeln(lightGreen.wrap("use /help or help to see available commands"));
  } catch (e) {
    stdout.writeln(red.wrap("shi broke..."));
  }
  // 3. REPL!
  stdout.write(magenta.wrap("$atSign "));
  while (true) {
    // receive a String from stdin
    String? command = stdin.readLineSync(encoding: utf8);
    if (command != null) {
      command = command.trim();
      Response response;
      if (command == "help" || command.startsWith("_") || command.startsWith("/") || command.startsWith("\\")) {
        if (command != "help") {
          command = command.substring(1);
        }
        var parts = command.split(" ");
        String verb = parts[0];

        try {
          switch (verb) {
            case "help":
              printHelpInstructions();
              break;
            case "scan":
              String regex = (parts.length > 1 ? parts[1] : "");
              var values = await atClient!.getAtKeys(regex: regex);
              stdout.writeln(lightCyan.wrap(" => $values"));
            case "q":
              exit(0);
            case "quit":
              exit(0);
          }
        } catch (e) {}
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

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
  String atSign = "@jeremy0";
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
  AtClient atClient;
  try {
    stdout.writeln(blue.wrap("Connecting..."));
    atClient = await AtClientImpl.create(atSign, "soccer0", pref, remoteSecondary: remoteSecondary);
    at_repl.REPL repl = at_repl.REPL(atSign);
    var success = await repl.authenticate();
    stdout.writeln(green.wrap("Successfully Connected."));
  } catch (e) {
    stdout.writeln(red.wrap("shi broke..."));
  }
  // 3. REPL!

  while (true) {
    // receive a String from stdin
    stdout.writeln(magenta.wrap("wo"));
    // run the command in AtClient
  }
}

void printHelpInstructions() {}

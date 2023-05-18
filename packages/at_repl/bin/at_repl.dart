import 'package:args/args.dart';
import 'package:at_repl/at_repl.dart' as at_repl;
import 'dart:io';
import 'package:at_onboarding_cli/at_onboarding_cli.dart';

// REPL <rootUrl> <atSign> <verbose == true|false>
// argparser args
void main(List<String> arguments) {
  final ArgParser argParser = ArgParser()
    ..addOption("rootUrl", abbr: 'r')
    ..addOption("atSign")
    ..addFlag("verbose");

  // 1. onboard
  final AtOnboardingPreference() pref = AtOnboardingPreference();
  final AtOnboarding atOnboarding = AtOnboardingImpl();

  // 2. create atClient
  
  // 3. REPL!

  while (true) {
    stdout.write('@jeremy_0');
    // receive a String from stdin
    // run the command in AtClient
  }
}

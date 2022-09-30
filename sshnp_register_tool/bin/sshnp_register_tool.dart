import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:sshnp_register_tool/colors.dart';
import 'package:sshnp_register_tool/io_util.dart';
import 'package:sshnp_register_tool/api_util.dart';
import 'package:sshnp_register_tool/onboard_util.dart';
import 'package:sshnp_register_tool/systemd_util.dart';

/// Sets up your device's atSign for you. Just enter your email address and the binary will cycle through atSigns for you to choose from. Once you choose an atSign, it will prompt you for an OTP (one-time-password). Upon giving the correct OTP, it will activate your atSign and generate an .atKeys file inside the `~/.atsign/keys/` directory.
/// This binary should realistically be only ran once to initialize and register the device's atSign.
/// If you go to your emails' atSigns dashboard (at `my.atsign.com/dashboard`), you can reset/delete the atSign and the atSign's keys will no longer work on the device. You can re-activate your atSign by onboarding via one of our apps or [at_onboarding_cli](https://github.com/atsign-foundation/at_libraries/tree/trunk/at_onboarding_cli)
/// Run this file via `dart run bin/register_tool.dart -e <email@email.com>`

const String defaultRootUrl = 'root.atsign.org:64';
const String keysDirectory = '~/.atsign/keys/';

void main(List<String> args) {
  final ArgParser parser = _initParser();

  late ArgResults results;
  try {
    results = parser.parse(args);
  } catch (exception) {
    _printUsage(parser);
    exit(1);
  }

  final String email = results['email'];
  final String rootUrl = results['rooturl'];

  if (!_isValidEmail(email)) {
    print(
        '\'$email\' is an invalid email. Try something like \'info@atsign.com\'');
    return;
  }

  if (!_isValidRootUrl(rootUrl)) {
    print(
        '\'$rootUrl\' is an invalid root url. Try something like \'root.atsign.org:64\'');
    return;
  }

  final ApiUtil registerUtil = ApiUtil();

  startRepl(registerUtil, email, rootUrl);
}

/// ====================================================
/// REPL
/// ====================================================

Future<void> startRepl(
    ApiUtil registerUtil, String email, String rootUrl) async {
  print('${Colors.white.code}Welcome to the sshnp setup tool!');

  print(
      'Which one are you? (\'${Colors.red.code}c${Colors.white.code}\'=client or \'${Colors.red.code}d${Colors.white.code}\'=device)');
  String choice = IOUtil.getChoice();
  if (!['c', 'd'].contains(choice)) {
    print('Invalid choice. (c/d)\n');
    startRepl(registerUtil, email, rootUrl);
    exit(1);
  }

  if (choice == 'c') {
    print('${Colors.green.code}You entered the client setup tool.${Colors.white.code}');
    do {
      IOUtil.printClientUsage();
      choice = IOUtil.getChoice();
    } while (!['1', '2'].contains(choice));

    if (choice == '1') {
      await _registerNewAtSign(registerUtil, email, rootUrl);
    } else if (choice == '2') {
      await _onboardUnactivatedAtSign(registerUtil, rootUrl);
    }
  } else if (choice == 'd') {
    print('You entered the device setup tool.');
    do {
      IOUtil.printDeviceUsage();
      choice = IOUtil.getChoice();
    } while (!['1', '2', '3'].contains(choice));

    if (choice == '1') {
      await _registerNewAtSign(registerUtil, email, rootUrl);
    } else if (choice == '2') {
      await _onboardUnactivatedAtSign(registerUtil, rootUrl);
    } else if (choice == '3') {
      await SystemdUtil.writeSshnpdService();
      print('${Colors.green.code}Looks like everything went well :)');
      print('Type ${Colors.yellow.code}sudo nano etc/systemd/system/sshnpd.service ${Colors.green.code}to modify ${Colors.yellow.code}line 11 ${Colors.green.code}with the correct atSigns.');
      print(Colors.white.code);
    }
  }
}

/// ====================================================
/// REPL supporting functions
/// 1. _registerNewAtSign(...) -> generate keys for a completely new atSign
/// 2. _onboardingUnactivatedAtSign(...) -> generate keys for an owned atSign but not already onboarded
/// ====================================================

/// Gives the option to choose a new atSign (from select 5 and can refresh)
/// Once chosen an atSign, ask for the OTP via their email
/// If successful, keys will be generated in ~/.atsign/keys/ and the atSign will be activated & onboarded
Future<void> _registerNewAtSign(
  ApiUtil registerUtil,
  String email,
  String rootUrl,
  {int numAtSigns = 5}
) async {
  String choice;

  List<String> atSigns;
  choice = 'r';
  do {
    print('${Colors.white.code}Choose an atSign from the list below:');
    atSigns = await registerUtil.getFreeAtSigns(numAtSigns);
    IOUtil.printAtSigns(atSigns);
    print('${Colors.cyan.code}r to refresh${Colors.white.code}');
    choice = IOUtil.getChoice();
  } while (choice == 'r' ||
      ((int.parse(choice) > numAtSigns) || int.parse(choice) <= 0));
  final String atSign = IOUtil.formatAtSign(atSigns[int.parse(choice) - 1]);
  print('${Colors.green.code}You chose $atSign');
  final bool sentSuccessfully = await registerUtil.registerAtSign(atSign, email);
  if (!sentSuccessfully) {
    print(
        '${Colors.red.code}Something went wrong. You might have sent an incorrect atSign \'$atSign\'. Please try again.${Colors.white.code}');
    exit(1);
  }
  print('${Colors.magenta.code}Enter the OTP sent to your email ($email):');
  final String otp = IOUtil.getChoice(prompt: false)
      .trim()
      .replaceAll('/\u001b[.*?m/g', '')
      .replaceAll('\n', '')
      .toUpperCase(); // remove new line and color codes. also uppercase.
  final String? cram = await registerUtil.registerAtSignValidate(atSign, email, otp);
  if (cram == null) {
    print('${Colors.red.code}Something went wrong. Please try again.${Colors.white.code}');
    exit(1);
  }

  final bool onboarded = await OnboardingUtil.onboard(atSign, rootUrl, cram);
  if (onboarded) {
    print('${Colors.green.code}You have successfully onboarded your atSign $atSign${Colors.white.code}');
    print('${Colors.green.code}$atSign\'s keys can be found in ${Colors.yellow.code}~/.atsign/keys/${atSign}_key.atKeys${Colors.white.code}');
  } else {
    print('${Colors.red.code}mOnboard unsuccessful. Please try again.');
  }
}

/// Onboard an unactivated atSign
/// Unactivated atSign = owned atSign, meaning it exists on your dashboard and unactivated because it was never onboarded before and never had keys generated (or was recently reset)
Future<void> _onboardUnactivatedAtSign(
    ApiUtil registerUtil, String rootUrl) async {
  print('${Colors.magenta.code}What is the unactivated atSign that you own?: ');
  final String atSign = IOUtil.formatAtSign(IOUtil.getChoice(prompt: false));
  final bool successfullySent =
      await registerUtil.authenticateAtSign(atSign); // true if otp sent
  if (!successfullySent) {
    print(
        '${Colors.red.code}Something went wrong when sending your OTP. Ensure that the atSign \'$atSign\' is an atSign that you own. Please try again.');
    exit(1);
  } else {
    print('${Colors.white.code}Successfully sent otp to the email that owns the atSign.');
  }
  print('${Colors.magenta.code}Enter the OTP sent to your email (that owns the atSign)');
  final String otp = IOUtil.getChoice(prompt: false).toUpperCase();
  final String? cram = await registerUtil.authenticateAtSignValidate(atSign, otp);

  if (cram == null) {
    print(
        '${Colors.red.code}Something went wrong when activating your atSign. Please try again.');
    print(otp);
    exit(1);
  }

  await registerUtil.runUntilSecondaryExists(rootUrl, atSign);

  final bool onboarded = await OnboardingUtil.onboard(atSign, rootUrl, cram);

  if (onboarded) {
    print('${Colors.green.code}You have successfully onboarded your atSign $atSign${Colors.white.code}');
        print('${Colors.green}$atSign\'s keys can be found in ${Colors.yellow.code}~/.atsign/keys/${atSign}_key.atKeys${Colors.white.code}');

  } else {
    print('${Colors.red.code}Onboard unsuccessful. Please try again.');
  }
}

/// ====================================================
/// Helper functions to make main() easier to read
/// ====================================================

void _printUsage(ArgParser parser) {
  String b;
  b = '\n';
  b += 'Usage: ./sshnp_register_tool -e <email>';
  b += '\n';
  b += '${parser.usage}\n';
  print(b);
}

ArgParser _initParser() {
  final ArgParser parser = ArgParser();

  parser.addOption(
    'email',
    abbr: 'e',
    mandatory: true,
    help: 'Email that your atSign will be registered to',
  );

  parser.addOption(
    'rooturl',
    abbr: 'r',
    mandatory: false,
    help: 'Root URL with host and port',
    defaultsTo: defaultRootUrl,
  );

  return parser;
}

bool _isValidEmail(String? email) {
  return email != null && email.isNotEmpty && email.contains('@');
}

bool _isValidRootUrl(String? rootUrl) {
  return rootUrl != null && rootUrl.isNotEmpty && rootUrl.contains(':');
}

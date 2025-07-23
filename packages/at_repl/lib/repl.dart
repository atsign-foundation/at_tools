import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:at_client/at_client.dart';
import 'package:at_onboarding_cli/at_onboarding_cli.dart';
import 'package:at_repl/repl_exception.dart';
import 'package:io/ansi.dart';

// /inspect command provides interactive key browsing with default filtering

class REPL {
  late Stream<String> inputStream;
  late IOSink outputStream;
  late AtClient atClient;

  REPL({
    Stream<String>? inputStream,
    IOSink? outputStream,
  }) {
    this.inputStream = inputStream ?? stdin.transform(utf8.decoder).transform(const LineSplitter());
    this.outputStream = outputStream ?? stdout;
  }

  void authenticate({required String rootDomain, required int rootPort, required String atSign}) {
    Future<bool> success = _pkamAuth(rootDomain, rootPort, atSign);
    success.then((value) {
      if (!value) {
        outputStream.writeln(red.wrap("Authentication failed. Please check your credentials."));
        exit(1);
      }
    }).catchError((error) {
      outputStream.writeln(red.wrap("Error during authentication: $error"));
      exit(1);
    });
  }

  void start() {
    // Start the REPL loop
  }

  Future<bool> _pkamAuth(final String rootDomain, final int rootPort, final String atSign) async {
    AtOnboardingPreference pref = AtOnboardingPreference()
      ..namespace = 'at_repl'
      ..rootDomain = rootDomain
      ..rootPort = rootPort
      ;
    AtOnboardingService service = AtOnboardingServiceImpl(atSign, pref);
    bool success = await service.authenticate();
    if(success) {
      atClient = service.atClient!;
      return true;
    }
    return success;
  }


  // TODO write function to handle raw protocol command, which uses _executeCommand

  /// This function is for executing protocol verbs
  /// Make sure that you add a \n at the end of the command so that you can get a return string back
  Future<String> _executeCommand(String command) async {
    final RemoteSecondary rs = atClient.getRemoteSecondary()!;
    final String? response = (await rs.executeCommand(command, auth: true));
    if (response == null) {
      throw REPLException(
          'Result is null for some reason after executing command: $command');
    }
    return response;
  }

}

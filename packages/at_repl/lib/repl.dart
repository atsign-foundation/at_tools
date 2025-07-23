import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:at_client/at_client.dart';
import 'package:at_onboarding_cli/at_onboarding_cli.dart';
import 'package:at_repl/repl_exception.dart';
import 'package:io/ansi.dart';
import 'features/help.dart';
import 'features/get.dart';
import 'features/put.dart';
import 'features/delete.dart';
import 'features/scan.dart';
import 'features/inspect_keys.dart';
import 'features/inspect_notifications.dart';
import 'features/monitor.dart';

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

  Future<bool> authenticate({required String rootDomain, required int rootPort, required String atSign}) async {
    return await _pkamAuth(rootDomain, rootPort, atSign);
  }

  void start() {
    outputStream.writeln("${green.wrap("at_repl started") ?? "at_repl started"}. ${cyan.wrap("Type /help for available commands or /exit to quit.") ?? "Type /help for available commands or /exit to quit."}");

    inputStream.listen((String input) {
      input = input.trim();

      if (input.isEmpty) return;

      if (input.startsWith('/')) {
        _handleCommand(input);
      } else {
        _handleRawProtocolCommand(input);
      }
    });
  }


  void _handleCommand(String input) {
    try {
      if (input == '/q' || input == '/quit') {
        outputStream.writeln(green.wrap("Goodbye!"));
        exit(0);
      } else if (input == '/help') {
        printUsage(outputStream);
      } else if (input.startsWith('/get ')) {
        handleGet(input, atClient, outputStream);
      } else if (input.startsWith('/put ')) {
        handlePut(input, atClient, outputStream);
      } else if (input.startsWith('/delete ')) {
        handleDelete(input, atClient, outputStream);
      } else if (input.startsWith('/scan')) {
        handleScan(input, atClient, outputStream);
      } else if (input.startsWith('/inspect')) {
        handleInspectKeys(input, atClient, outputStream);
      } else if (input.startsWith('/interactive')) {
        handleInspectNotifications(input, atClient, outputStream, executeCommand: _executeCommand);
      } else if (input.startsWith('/monitor')) {
        handleMonitor(input, atClient, outputStream);
      } else {
        outputStream.writeln(red.wrap("Unknown command: $input"));
      }
    } catch (e) {
      outputStream.writeln(red.wrap("Error: $e"));
    }
  }
  
  void _handleRawProtocolCommand(String input) {
    if (!input.endsWith('\n')) {
      input += '\n';
    }
    outputStream.writeln("Executing raw command: ${input.trim()}");
    _executeCommand(input).then((response) {
      outputStream.writeln("Response: $response");
    }).catchError((error) {
      outputStream.writeln(red.wrap("Error executing command: $error"));
    });
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

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
import 'features/inspect_keys.dart' as inspect_keys;
import 'features/inspect_notifications.dart' as inspect_notifications;
import 'features/monitor.dart' as monitor;

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

  Future<bool> authenticate({required String rootDomain, required int rootPort, required String atSign, String? keysFile}) async {
    return await _pkamAuth(rootDomain, rootPort, atSign, keysFile);
  }

  void start() {
    outputStream.writeln("${green.wrap("at_repl started") ?? "at_repl started"}. ${cyan.wrap("Type /help for available commands or /exit to quit.") ?? "Type /help for available commands or /exit to quit."}");
    _showPrompt();

    inputStream.listen((String input) {
      input = input.trim();

      if (input.isEmpty) {
        _showPrompt();
        return;
      }

      // Check if we're in interactive mode
      if (_handleInteractiveInput(input)) {
        return;
      }

      if (input.startsWith('/')) {
        _handleCommand(input);
      } else {
        _handleRawProtocolCommand(input);
      }
      
      _showPrompt();
    });
  }

  void _showPrompt() {
    final atSign = _getAtSign();
    if (inspect_keys.isInInteractiveMode) {
      if (inspect_keys.isWaitingForAction) {
        outputStream.write("$atSign (v/d): ");
      } else {
        outputStream.write("$atSign (inspect): ");
      }
    } else if (inspect_notifications.isInNotificationInteractiveMode) {
      if (inspect_notifications.isWaitingForNotificationAction) {
        outputStream.write("$atSign (v/d): ");
      } else {
        outputStream.write("$atSign (notify): ");
      }
    } else if (monitor.isInMonitorMode) {
      outputStream.write("$atSign (monitor): ");
    } else {
      outputStream.write("$atSign: ");
    }
    
    if (outputStream == stdout) {
      stdout.flush();
    }
  }

  String _getAtSign() {
    try {
      return atClient.getCurrentAtSign() ?? "@unknown";
    } catch (e) {
      return "@unknown";
    }
  }

  Future<bool> _pkamAuth(final String rootDomain, final int rootPort, final String atSign, final String? keysFile) async {
    AtOnboardingPreference pref = AtOnboardingPreference()
      ..namespace = 'at_repl'
      ..rootDomain = rootDomain
      ..rootPort = rootPort;
    
    if (keysFile != null) {
      pref.atKeysFilePath = keysFile;
    }
    
    AtOnboardingService service = AtOnboardingServiceImpl(atSign, pref);
    bool success = await service.authenticate();
    if(success) {
      atClient = service.atClient!;
      return true;
    }
    return success;
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
      } else if (input.startsWith('/inspect_notify')) {
        inspect_notifications.handleInspectNotifications(input, atClient, outputStream, executeCommand: _executeCommand);
      } else if (input.startsWith('/inspect')) {
        inspect_keys.handleInspectKeys(input, atClient, outputStream);
      } else if (input.startsWith('/monitor')) {
        monitor.handleMonitor(input, atClient, outputStream);
      } else {
        outputStream.writeln(red.wrap("Unknown command: $input"));
      }
    } catch (e) {
      outputStream.writeln(red.wrap("Error: $e"));
    }
  }

  bool _handleInteractiveInput(String input) {
    // Check if we're in key inspection interactive mode
    if (inspect_keys.isInInteractiveMode) {
      if (inspect_keys.isWaitingForAction) {
        final handled = inspect_keys.handleActionInput(input);
        if (handled) {
          // Show prompt after async operations complete
          Future.delayed(Duration(milliseconds: 10), () => _showPrompt());
        }
        return handled;
      } else {
        final handled = inspect_keys.handleInteractiveInput(input);
        if (handled) {
          Future.delayed(Duration(milliseconds: 10), () => _showPrompt());
        }
        return handled;
      }
    }
    
    // Check if we're in notification inspection interactive mode
    if (inspect_notifications.isInNotificationInteractiveMode) {
      if (inspect_notifications.isWaitingForNotificationAction) {
        final handled = inspect_notifications.handleNotificationActionInput(input);
        if (handled) {
          Future.delayed(Duration(milliseconds: 10), () => _showPrompt());
        }
        return handled;
      } else {
        final handled = inspect_notifications.handleNotificationInteractiveInput(input);
        if (handled) {
          Future.delayed(Duration(milliseconds: 10), () => _showPrompt());
        }
        return handled;
      }
    }
    
    // Check if we're in monitor mode
    if (monitor.isInMonitorMode) {
      final handled = monitor.handleMonitorInput(input);
      if (handled) {
        Future.delayed(Duration(milliseconds: 10), () => _showPrompt());
      }
      return handled;
    }
    
    return false;
  }

}

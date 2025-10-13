import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:at_client/at_client.dart';
import 'package:at_onboarding_cli/at_onboarding_cli.dart';
import 'package:at_utils/at_utils.dart';
import 'package:at_repl/repl_exception.dart';
import 'package:io/ansi.dart';
import 'interactive_session.dart';
import 'repl_mode.dart';
import 'features/help.dart';
import 'features/get.dart';
import 'features/put.dart';
import 'features/delete.dart';
import 'features/scan.dart';
import 'features/inspect_keys.dart';
import 'features/inspect_notifications.dart';
import 'features/monitor.dart';
import 'constants.dart';

class REPL {
  late Stream<String> inputStream;
  late IOSink outputStream;
  late AtClient atClient;
  InteractiveSession? currentSession;
  ReplMode currentMode = ReplMode.main;

  REPL({
    Stream<String>? inputStream,
    IOSink? outputStream,
  }) {
    this.inputStream = inputStream ??
        stdin.transform(utf8.decoder).transform(const LineSplitter());
    this.outputStream = outputStream ?? stdout;
  }

  Future<bool> authenticate({
    required String rootDomain,
    required int rootPort,
    required String atSign,
    String? keysPath,
  }) async {
    return await _pkamAuth(rootDomain, rootPort, atSign, keysPath);
  }

  void start() {
    outputStream.writeln(
        "${green.wrap("at_repl started") ?? "at_repl started"}. ${cyan.wrap("Type /help for available commands or /quit to quit.") ?? "Type /help for available commands or /quit to quit."}");
    _showPrompt();

    inputStream.listen((String input) {
      input = input.trim();

      if (input.isEmpty) {
        _showPrompt();
        return;
      }

      // Check if we're in interactive mode
      if (currentSession != null && currentSession!.isActive) {
        final continueSession = currentSession!.handleInput(input);
        if (!continueSession || !currentSession!.isActive) {
          currentSession = null;
          currentMode = ReplMode.main;
        }
        _showPrompt();
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
    if (currentSession != null && currentSession!.isActive) {
      outputStream.write("$atSign ${currentSession!.getPrompt()}");
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

  Future<bool> _pkamAuth(final String rootDomain, final int rootPort,
      final String atSign, final String? keysPath) async {
    AtOnboardingPreference pref = AtOnboardingPreference()
      ..namespace = 'at_repl'
      ..rootDomain = rootDomain
      ..rootPort = rootPort;

    final String? resolvedKeysPath = _resolveKeysFilePath(keysPath, atSign);
    if (resolvedKeysPath != null) {
      pref.atKeysFilePath = resolvedKeysPath;
    }

    AtOnboardingService service = AtOnboardingServiceImpl(atSign, pref);
    bool success = await service.authenticate();
    if (success) {
      atClient = service.atClient!;
      return true;
    }
    return success;
  }

  String? _resolveKeysFilePath(String? keysPath, String atSign) {
    if (keysPath == null) {
      return null;
    }

    final String trimmed = keysPath.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final String expanded = _expandHomeDirectory(trimmed);
    if (expanded.toLowerCase().endsWith('.atkeys')) {
      return expanded;
    }

    final String normalizedAtSign = AtUtils.fixAtSign(atSign);
    final bool hasTrailingSeparator =
        expanded.endsWith('/') || expanded.endsWith('\\');
    final String dir =
        hasTrailingSeparator ? expanded : '$expanded${Platform.pathSeparator}';
    return '$dir${normalizedAtSign}_key.atKeys';
  }

  String _expandHomeDirectory(String path) {
    if (!path.startsWith('~')) {
      return path;
    }

    final String? homeDirectory =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (homeDirectory == null || homeDirectory.isEmpty) {
      return path;
    }
    if (path == '~') {
      return homeDirectory;
    }
    return path.replaceFirst('~', homeDirectory);
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
        _handleInspectNotifications(input);
      } else if (input.startsWith('/inspect')) {
        _handleInspectKeys(input);
      } else if (input.startsWith('/monitor')) {
        _handleMonitor(input);
      } else {
        outputStream.writeln(red.wrap("Unknown command: $input"));
      }
    } catch (e) {
      outputStream.writeln(red.wrap("Error: $e"));
    }
  }

  void _handleInspectKeys(String input) async {
    final parts = input.split(' ');
    String? userRegex = parts.length > 1 ? parts.sublist(1).join(' ') : null;
    if (userRegex != null) {
      userRegex = userRegex.trim();
      if (userRegex.isEmpty) {
        userRegex = null;
      }
    }
    String actualRegex = userRegex ?? defaultInspectRegex;
    try {
      outputStream
          .writeln(cyan.wrap("Inspecting keys with regex: '$actualRegex' ..."));
      final totalKeys =
          await getAtKeys(atClient, regex: '.*', showHiddenKeys: true);
      final keys =
          await getAtKeys(atClient, regex: actualRegex, showHiddenKeys: true);
      if (keys.isEmpty) {
        outputStream.writeln(lightYellow
            .wrap("No keys found (0 of ${totalKeys.length} total keys)"));
        return;
      }
      outputStream.writeln(green
          .wrap("\nShowing ${keys.length} of ${totalKeys.length} key(s):"));
      currentSession = InspectKeysSession(keys, atClient, outputStream);
      currentMode = ReplMode.inspectKeys;
    } catch (e) {
      outputStream.writeln(red.wrap("Error inspecting keys: $e"));
    }
  }

  void _handleInspectNotifications(String input) async {
    try {
      outputStream.writeln(cyan.wrap("Fetching notifications..."));

      final response = await _executeCommand("notify:list\n");
      // remove data: prefix if present
      final cleanedResponse = response.replaceAll(RegExp(r'^data:\s*'), '');
      if (cleanedResponse.isEmpty || cleanedResponse == '[]') {
        outputStream.writeln(lightYellow.wrap("No notifications found"));
        return;
      }
      final notifications = parseNotifications(cleanedResponse);

      if (notifications.isEmpty) {
        outputStream.writeln(lightYellow.wrap("No notifications found"));
        return;
      }

      outputStream.writeln(
          green.wrap("\nFound ${notifications.length} notification(s):"));

      currentSession = InspectNotificationsSession(
          notifications, outputStream, _executeCommand);
      currentMode = ReplMode.inspectNotifications;
    } catch (e) {
      outputStream.writeln(red.wrap("Error inspecting notifications: $e"));
    }
  }

  void _handleMonitor(String input) {
    final parts = input.split(' ');
    String? regex = parts.length > 1 ? parts.sublist(1).join(' ') : null;

    if (regex == null || regex.isEmpty) {
      regex = defaultMonitorRegex;
    }

    try {
      currentSession =
          MonitorSession(atClient, regex: regex, output: outputStream);
      currentMode = ReplMode.monitor;
    } catch (e) {
      outputStream.writeln(red.wrap("Error starting monitor: $e"));
    }
  }
}

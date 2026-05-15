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
    required AtRootDomain rootDomain,
    required String atSign,
    String? keysPath,
  }) async {
    return await _pkamAuth(rootDomain, atSign, keysPath);
  }

  void start() {
    outputStream.writeln(
        "${green.wrap("at_repl started") ?? "at_repl started"}. ${cyan.wrap("Type /help for available commands or /quit to quit.") ?? "Type /help for available commands or /quit to quit."}");
    _showPrompt();

    final subscription = inputStream.listen(null);
    subscription.onData((String input) {
      subscription.pause();
      _processInput(input).catchError((error, stackTrace) {
        outputStream.writeln(red.wrap("Error: $error"));
      }).whenComplete(() {
        _showPrompt();
        subscription.resume();
      });
    });
    subscription.onError((Object error, StackTrace stackTrace) {
      outputStream.writeln(red.wrap("Stream error: $error"));
    });
  }

  Future<void> _processInput(String rawInput) async {
    final input = rawInput.trim();

    if (input.isEmpty) {
      return;
    }

    try {
      if (currentSession != null && currentSession!.isActive) {
        final continueSession = currentSession!.handleInput(input);
        if (!continueSession || !currentSession!.isActive) {
          currentSession = null;
          currentMode = ReplMode.main;
        }
        return;
      }

      if (input.startsWith('/')) {
        await _handleCommand(input);
      } else {
        await _handleRawProtocolCommand(input);
      }
    } catch (e) {
      outputStream.writeln(red.wrap("Error: $e"));
    }
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

  Future<bool> _pkamAuth(final AtRootDomain rootDomain,
      final String atSign, final String? keysPath) async {
    AtOnboardingPreference pref = AtOnboardingPreference()
      ..namespace = 'at_repl'
      ..rootDomain = rootDomain.rootDomain
      ..rootPort = rootDomain.rootPort;

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

  Future<void> _handleRawProtocolCommand(String input) async {
    if (!input.endsWith('\n')) {
      input += '\n';
    }
    try {
      outputStream.writeln("Executing raw command: ${input.trim()}");
      final response = await _executeCommand(input);
      outputStream.writeln("Response: $response");
    } catch (error) {
      outputStream.writeln(red.wrap("Error executing command: $error"));
    }
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

  Future<void> _handleCommand(String input) async {
    try {
      if (input == '/q' || input == '/quit') {
        outputStream.writeln(green.wrap("Goodbye!"));
        exit(0);
      } else if (input == '/help') {
        printUsage(outputStream);
      } else if (input.startsWith('/get ')) {
        await handleGet(input, atClient, outputStream);
      } else if (input.startsWith('/put ')) {
        await handlePut(input, atClient, outputStream);
      } else if (input.startsWith('/delete ')) {
        await handleDelete(input, atClient, outputStream);
      } else if (input.startsWith('/scan')) {
        await handleScan(input, atClient, outputStream);
      } else if (input.startsWith('/inspect_notify')) {
        await _handleInspectNotifications(input);
      } else if (input.startsWith('/inspect')) {
        await _handleInspectKeys(input);
      } else if (input.startsWith('/monitor')) {
        await _handleMonitor(input);
      } else {
        outputStream.writeln(red.wrap("Unknown command: $input"));
      }
    } catch (e) {
      outputStream.writeln(red.wrap("Error: $e"));
    }
  }

  Future<void> _handleInspectKeys(String input) async {
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
      final totalKeys = await getAtKeys(atClient, showHiddenKeys: true);
      RegExp compiledRegex;
      try {
        compiledRegex = RegExp(actualRegex);
      } on FormatException catch (e) {
        outputStream.writeln(red
            .wrap("Invalid regular expression '$actualRegex': ${e.message}"));
        return;
      }

      final keys = totalKeys
          .where((key) => compiledRegex.hasMatch(key.toString()))
          .toList();
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

  Future<void> _handleInspectNotifications(String input) async {
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

  Future<void> _handleMonitor(String input) async {
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

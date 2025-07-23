import 'dart:convert';
import 'dart:io';

import 'package:at_client/at_client.dart';
import 'package:io/ansi.dart';

const String defaultRegex = '^(?!.*statsNotification).*';

// Global state for monitor interactive mode
MonitorSession? _currentMonitorSession;
bool _inMonitorMode = false;

class MonitorSession {
  late AtClient atClient;
  late String? regex;
  late bool shouldDecrypt;
  late IOSink? output;

  MonitorSession(this.atClient,
      {this.regex, this.shouldDecrypt = true, this.output}) {
    if (regex == null || regex!.isEmpty) {
      regex = defaultRegex;
    }
    output ??= stdout;
    Stream<AtNotification> stream = atClient.notificationService
        .subscribe(regex: regex, shouldDecrypt: shouldDecrypt);
    stream.listen(_onData);
  }

  void _onData(AtNotification atNotification) {
    // --- raw notification ---
    // <raw notification>
    // --- decrypted value ---
    // <decrypted value>
    // --- json formatted value ---
    // <json value>

    output!.writeln(yellow.wrap('\nRaw notification:'));
    output!.writeln(atNotification);
    if (shouldDecrypt && atNotification.value != null) {
      output!.writeln(green.wrap('Decrypted value:'));
      output!.writeln(atNotification.value!);
      try {
        final Map<String, dynamic> jsonValue =
            jsonDecode(atNotification.value!);
        output!.writeln(cyan.wrap('JSON formatted value:'));
        output!.writeln(jsonValue);
      } catch (e) {
        // output!.writeln('Error parsing JSON: $e');
      }
    }
  }

  void stop() {
    atClient.notificationService.stopAllSubscriptions();
    output!.writeln('Monitor session stopped.');
  }
}

void handleMonitor(String input, AtClient atClient, IOSink outputStream) {
  final parts = input.split(' ');
  String? regex = parts.length > 1 ? parts.sublist(1).join(' ') : null;

  // If no regex provided, use default filter to exclude statsNotification
  if (regex == null || regex.isEmpty) {
    regex = defaultRegex;
  }

  try {
    outputStream.writeln(green.wrap(
        "Starting monitor${regex != defaultRegex ? ' with regex: $regex' : ' (excluding statsNotification)'}..."));
    outputStream.writeln(cyan.wrap("Type 'q' to stop monitoring"));

    _currentMonitorSession = MonitorSession(
      atClient,
      regex: regex,
      shouldDecrypt: true,
      output: outputStream,
    );

    _inMonitorMode = true;
    outputStream.writeln(lightYellow.wrap(
        "Monitor session started. Using regex: '${_currentMonitorSession!.regex}'. Waiting for notifications..."));
  } catch (e) {
    outputStream.writeln(red.wrap("Error starting monitor: $e"));
  }
}

bool handleMonitorInput(String input) {
  if (!_inMonitorMode || _currentMonitorSession == null) return false;

  input = input.trim().toLowerCase();

  if (input == 'q' || input == 'quit') {
    _currentMonitorSession!.stop();
    _currentMonitorSession!.output!
        .writeln(green.wrap("Monitor session stopped"));
    _exitMonitorMode();
    return true;
  }

  // For any other input during monitoring, show help
  _currentMonitorSession!.output!
      .writeln(cyan.wrap("Type 'q' to quit monitoring"));
  return true;
}

void _exitMonitorMode() {
  _inMonitorMode = false;
  _currentMonitorSession = null;
}

bool get isInMonitorMode => _inMonitorMode;

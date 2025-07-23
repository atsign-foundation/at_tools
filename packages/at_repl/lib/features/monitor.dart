import 'dart:convert';
import 'dart:io';
import 'package:at_client/at_client.dart';
import 'package:io/ansi.dart';
import '../constants.dart';
import '../interactive_session.dart';

void handleMonitor(String input, AtClient atClient, IOSink outputStream) {
  // This function is kept for backwards compatibility but should not be used
  // Use MonitorSession instead
  throw UnsupportedError("Use MonitorSession instead of this deprecated function");
}

bool handleMonitorInput(String input) {
  // This function is kept for backwards compatibility but should not be used
  // Use MonitorSession instead
  throw UnsupportedError("Use MonitorSession instead of this deprecated function");
}

bool get isInMonitorMode => throw UnsupportedError("Use session-based approach instead");

class MonitorSession implements InteractiveSession {
  final AtClient _atClient;
  final String _regex;
  final bool _shouldDecrypt;
  final IOSink _output;
  bool _isActive = true;

  MonitorSession(this._atClient, {String? regex, bool shouldDecrypt = true, IOSink? output})
      : _regex = regex ?? defaultMonitorRegex,
        _shouldDecrypt = shouldDecrypt,
        _output = output ?? stdout {
    
    _output.writeln(green.wrap(
        "Starting monitor${_regex != defaultMonitorRegex ? ' with regex: $_regex' : ' (excluding statsNotification)'}..."));
    _output.writeln(cyan.wrap("Type 'q' to stop monitoring"));
    
    Stream<AtNotification> stream = _atClient.notificationService
        .subscribe(regex: _regex, shouldDecrypt: _shouldDecrypt);
    stream.listen(_onData);
    
    _output.writeln(lightYellow.wrap(
        "Monitor session started. Using regex: '$_regex'. Waiting for notifications..."));
  }

  void _onData(AtNotification atNotification) {
    if (!_isActive) return;
    
    _output.writeln(yellow.wrap('\nRaw notification:'));
    _output.writeln(atNotification);
    if (_shouldDecrypt && atNotification.value != null) {
      _output.writeln(green.wrap('Decrypted value:'));
      _output.writeln(atNotification.value!);
      try {
        final Map<String, dynamic> jsonValue =
            jsonDecode(atNotification.value!);
        _output.writeln(cyan.wrap('JSON formatted value:'));
        _output.writeln(jsonValue);
      } catch (e) {
        // Not JSON, that's fine
      }
    }
  }

  @override
  bool handleInput(String input) {
    if (!_isActive) return false;
    
    input = input.trim().toLowerCase();

    if (input == 'q' || input == 'quit') {
      _output.writeln(green.wrap("Monitor session stopped"));
      exit();
      return false;
    }

    // For any other input during monitoring, show help
    _output.writeln(cyan.wrap("Type 'q' to quit monitoring"));
    return true;
  }

  @override
  String getPrompt() {
    return "monitor> ";
  }

  @override
  bool get isActive => _isActive;

  @override
  void exit() {
    _isActive = false;
    _atClient.notificationService.stopAllSubscriptions();
  }
}

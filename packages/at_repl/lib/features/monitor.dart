import 'dart:convert';
import 'dart:io';

import 'package:at_client/at_client.dart';

const String defaultRegex = 'TODO';

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

    output!.writeln('--- raw notification ---');
    output!.writeln(atNotification);
    if (shouldDecrypt && atNotification.value != null) {
      output!.writeln('--- decrypted value ---');
      try {
        final Map<String, dynamic> jsonValue = jsonDecode(atNotification.value!);
        output!.writeln('--- json formatted value ---');
        output!.writeln(jsonValue);
      } catch (e) {
        output!.writeln('Error parsing JSON: $e');
      }
    }
  }
}

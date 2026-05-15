import 'dart:io';
import 'package:at_client/at_client.dart';
import 'package:io/ansi.dart';

Future<bool> put(AtClient atClient,
    {required String atKeyStr, required String value}) async {
  return atClient.put(AtKey.fromString(atKeyStr), value,
      putRequestOptions: PutRequestOptions()..useRemoteAtServer = true);
}

Future<void> handlePut(
    String input, AtClient atClient, IOSink outputStream) async {
  final parts = input.split(' ');
  if (parts.length < 3) {
    outputStream.writeln(red.wrap("Usage: /put <atKey> <value>"));
    return;
  }
  final atKeyStr = parts[1];
  final value = parts.sublist(2).join(' ');

  try {
    final success = await put(atClient, atKeyStr: atKeyStr, value: value);
    if (success) {
      outputStream
          .writeln(green.wrap("Successfully stored: $atKeyStr = $value"));
    } else {
      outputStream.writeln(red.wrap("Failed to store key: $atKeyStr"));
    }
  } catch (e) {
    outputStream.writeln(red.wrap("Error storing key: $e"));
  }
}

import 'dart:io';
import 'package:at_client/at_client.dart';
import 'package:io/ansi.dart';

Future<String?> get(AtClient atClient, {required String atKeyStr}) async {
  AtKey atKey = AtKey.fromString(atKeyStr);
  AtValue? atValue = await atClient.get(atKey,
      getRequestOptions: GetRequestOptions()..useRemoteAtServer = true);
  return atValue.value;
}

void handleGet(String input, AtClient atClient, IOSink outputStream) async {
  final parts = input.split(' ');
  if (parts.length < 2) {
    outputStream.writeln(red.wrap("Usage: /get <atKey>"));
    return;
  }
  final atKeyStr = parts.sublist(1).join(' ');
  
  try {
    final value = await get(atClient, atKeyStr: atKeyStr);
    if (value != null) {
      outputStream.writeln(green.wrap("Value: $value"));
    } else {
      outputStream.writeln(lightYellow.wrap("Key not found or has no value"));
    }
  } catch (e) {
    outputStream.writeln(red.wrap("Error getting key: $e"));
  }
}
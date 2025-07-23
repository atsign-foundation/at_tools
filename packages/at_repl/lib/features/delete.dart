import 'dart:io';
import 'package:at_client/at_client.dart';
import 'package:io/ansi.dart';

Future<bool> delete(AtClient atClient, {required String atKeyStr}) async {
  AtKey atKey = AtKey.fromString(atKeyStr);
  return await atClient.delete(atKey,
      deleteRequestOptions: DeleteRequestOptions()..useRemoteAtServer = true);
}

void handleDelete(String input, AtClient atClient, IOSink outputStream) async {
  final parts = input.split(' ');
  if (parts.length < 2) {
    outputStream.writeln(red.wrap("Usage: /delete <atKey>"));
    return;
  }
  final atKeyStr = parts.sublist(1).join(' ');
  
  try {
    final success = await delete(atClient, atKeyStr: atKeyStr);
    if (success) {
      outputStream.writeln(green.wrap("Successfully deleted: $atKeyStr"));
    } else {
      outputStream.writeln(red.wrap("Failed to delete key: $atKeyStr"));
    }
  } catch (e) {
    outputStream.writeln(red.wrap("Error deleting key: $e"));
  }
}
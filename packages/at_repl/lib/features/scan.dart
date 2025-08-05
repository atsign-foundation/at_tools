import 'dart:io';
import 'package:at_client/at_client.dart';
import 'package:io/ansi.dart';

Future<List<AtKey>> getAtKeys(AtClient atClient, {String? regex, bool showHiddenKeys = true}) async {
  return await atClient.getAtKeys(regex: regex, showHiddenKeys: showHiddenKeys);
}

void handleScan(String input, AtClient atClient, IOSink outputStream) async {
  final parts = input.split(' ');
  final regex = parts.length > 1 ? parts.sublist(1).join(' ') : null;
  
  try {
    outputStream.writeln(cyan.wrap("Scanning for keys${regex != null ? ' with regex: $regex' : ''}..."));
    final keys = await getAtKeys(atClient, regex: regex);
    
    if (keys.isEmpty) {
      outputStream.writeln(lightYellow.wrap("No keys found"));
      return;
    }
    
    outputStream.writeln(green.wrap("\nFound ${keys.length} key(s):"));
    outputStream.writeln("${'#'.padRight(5)} | Key");
    outputStream.writeln("${'─' * 5}─┼─${'─' * 50}");
    
    for (int i = 0; i < keys.length; i++) {
      final indexStr = (i + 1).toString().padRight(5);
      outputStream.writeln("$indexStr | ${keys[i].toString()}");
    }
    
  } catch (e) {
    outputStream.writeln(red.wrap("Error scanning keys: $e"));
  }
}
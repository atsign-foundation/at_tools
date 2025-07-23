
import 'dart:io';
import 'dart:convert';
import 'package:at_client/at_client.dart';
import 'package:io/ansi.dart';
import 'scan.dart';
import 'get.dart';
import 'delete.dart';

class InspectKeysResult {
  final List<AtKey> atKeys;
  final String regex;
  final bool shouldEnterInteractiveMode;

  InspectKeysResult(this.atKeys, this.regex, this.shouldEnterInteractiveMode);
}

void handleInspectKeys(String input, AtClient atClient, IOSink outputStream) async {
  final parts = input.split(' ');
  final regex = parts.length > 1 ? parts.sublist(1).join(' ') : null;
  
  try {
    outputStream.writeln(cyan.wrap("Inspecting keys${regex != null ? ' with regex: $regex' : ''}..."));
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
    
    outputStream.writeln(cyan.wrap("\nEntering interactive mode. Type a number to select a key, 'q' to quit."));
    
    await _enterInteractiveMode(keys, atClient, outputStream);
    
  } catch (e) {
    outputStream.writeln(red.wrap("Error inspecting keys: $e"));
  }
}

Future<void> _enterInteractiveMode(List<AtKey> keys, AtClient atClient, IOSink outputStream) async {
  final stdinStream = stdin.transform(utf8.decoder).transform(const LineSplitter());
  
  await for (String input in stdinStream) {
    input = input.trim();
    
    if (input.isEmpty) continue;
    
    if (input.toLowerCase() == 'q' || input.toLowerCase() == 'quit') {
      outputStream.writeln(green.wrap("Exiting interactive mode"));
      break;
    }
    
    final index = int.tryParse(input);
    if (index == null || index < 1 || index > keys.length) {
      outputStream.writeln(red.wrap("Invalid selection. Enter a number 1-${keys.length}, or 'q' to quit."));
      continue;
    }
    
    final selectedKey = keys[index - 1];
    outputStream.writeln(green.wrap("Selected: ${selectedKey.toString()}"));
    outputStream.writeln("Enter 'v' to view or 'd' to delete:");
    
    final actionInput = await stdinStream.first;
    final action = actionInput.trim().toLowerCase();
    
    if (action == 'v') {
      try {
        final value = await get(atClient, atKeyStr: selectedKey.toString());
        if (value != null) {
          outputStream.writeln(green.wrap("Value: $value"));
        } else {
          outputStream.writeln(lightYellow.wrap("Key has no value"));
        }
      } catch (e) {
        outputStream.writeln(red.wrap("Error getting value: $e"));
      }
    } else if (action == 'd') {
      try {
        final success = await delete(atClient, atKeyStr: selectedKey.toString());
        if (success) {
          outputStream.writeln(green.wrap("Successfully deleted: ${selectedKey.toString()}"));
          keys.removeAt(index - 1);
          
          if (keys.isEmpty) {
            outputStream.writeln(lightYellow.wrap("No more keys. Exiting interactive mode."));
            break;
          }
          
          outputStream.writeln(cyan.wrap("\nUpdated key list:"));
          outputStream.writeln("${'#'.padRight(5)} | Key");
          outputStream.writeln("${'─' * 5}─┼─${'─' * 50}");
          
          for (int i = 0; i < keys.length; i++) {
            final indexStr = (i + 1).toString().padRight(5);
            outputStream.writeln("$indexStr | ${keys[i].toString()}");
          }
        } else {
          outputStream.writeln(red.wrap("Failed to delete key"));
        }
      } catch (e) {
        outputStream.writeln(red.wrap("Error deleting key: $e"));
      }
    } else {
      outputStream.writeln(red.wrap("Invalid action. Enter 'v' to view or 'd' to delete."));
    }
    
    outputStream.writeln(cyan.wrap("\nType a number to select another key, or 'q' to quit."));
  }
}

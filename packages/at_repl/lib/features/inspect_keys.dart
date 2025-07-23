
import 'dart:io';
import 'dart:convert';
import 'package:at_client/at_client.dart';
import 'package:io/ansi.dart';
import 'scan.dart';
import 'get.dart';
import 'delete.dart';
import '../constants.dart';

class InspectKeysResult {
  final List<AtKey> atKeys;
  final String regex;
  final bool shouldEnterInteractiveMode;

  InspectKeysResult(this.atKeys, this.regex, this.shouldEnterInteractiveMode);
}

// Global state for interactive mode
List<AtKey>? _currentKeys;
AtClient? _currentAtClient;
IOSink? _currentOutputStream;
bool _inInteractiveMode = false;


void handleInspectKeys(String input, AtClient atClient, IOSink outputStream) async {
  final parts = input.split(' ');
  String? userRegex = parts.length > 1 ? parts.sublist(1).join(' ') : null;
  
  // Clean up the regex - remove extra whitespace
  if (userRegex != null) {
    userRegex = userRegex.trim();
    if (userRegex.isEmpty) {
      userRegex = null;
    }
  }
  
  // Use default regex if none provided, otherwise use user regex
  String actualRegex = userRegex ?? defaultInspectRegex;
  
  try {
    if (userRegex != null) {
      outputStream.writeln(cyan.wrap("Inspecting keys with regex: '$userRegex'..."));
    } else {
      outputStream.writeln(cyan.wrap("Inspecting keys with regex: '$defaultInspectRegex'..."));
    }
    
    // Get total count of all keys for comparison
    final totalKeys = await getAtKeys(atClient, regex: '.*', showHiddenKeys: true);
    final keys = await getAtKeys(atClient, regex: actualRegex, showHiddenKeys: true);
    
    if (keys.isEmpty) {
      outputStream.writeln(lightYellow.wrap("No keys found (0 of ${totalKeys.length} total keys)"));
      return;
    }
    
    outputStream.writeln(green.wrap("\nShowing ${keys.length} of ${totalKeys.length} key(s):"));
    outputStream.writeln("${'#'.padRight(5)} | Key");
    outputStream.writeln("${'─' * 5}─┼─${'─' * 50}");
    
    for (int i = 0; i < keys.length; i++) {
      final indexStr = (i + 1).toString().padRight(5);
      outputStream.writeln("$indexStr | ${keys[i].toString()}");
    }
    
    outputStream.writeln(cyan.wrap("\nEntering interactive mode. Type a number to select a key, 'l' to relist, or 'q' to quit."));
    
    // Set up interactive mode state
    _currentKeys = keys;
    _currentAtClient = atClient;
    _currentOutputStream = outputStream;
    _inInteractiveMode = true;
    
  } catch (e) {
    outputStream.writeln(red.wrap("Error inspecting keys: $e"));
  }
}

bool handleInteractiveInput(String input) {
  if (!_inInteractiveMode || _currentKeys == null) return false;
  
  input = input.trim();
  
  if (input.toLowerCase() == 'q' || input.toLowerCase() == 'quit') {
    _currentOutputStream!.writeln(green.wrap("Exiting interactive mode"));
    _exitInteractiveMode();
    return true;
  }
  
  if (input.toLowerCase() == 'l' || input.toLowerCase() == 'list') {
    _showKeyList();
    return true;
  }
  
  final index = int.tryParse(input);
  if (index == null || index < 1 || index > _currentKeys!.length) {
    _currentOutputStream!.writeln(red.wrap("Invalid selection. Enter a number 1-${_currentKeys!.length}, 'l' to relist, or 'q' to quit."));
    return true;
  }
  
  final selectedKey = _currentKeys![index - 1];
  _currentOutputStream!.writeln(green.wrap("Selected: ${selectedKey.toString()}"));
  _currentOutputStream!.writeln(cyan.wrap("Enter 'v' to view or 'd' to delete:"));
  
  // Set up state for action input
  _waitingForAction = true;
  _selectedKeyIndex = index - 1;
  
  return true;
}

bool _waitingForAction = false;
int _selectedKeyIndex = -1;

bool handleActionInput(String input) {
  if (!_waitingForAction || _currentKeys == null) return false;
  
  final action = input.trim().toLowerCase();
  final selectedKey = _currentKeys![_selectedKeyIndex];
  
  if (action == 'v') {
    _handleViewKey(selectedKey);
  } else if (action == 'd') {
    _handleDeleteKey(selectedKey, _selectedKeyIndex);
  } else {
    _currentOutputStream!.writeln(red.wrap("Invalid action. Enter 'v' to view or 'd' to delete."));
    return true;
  }
  
  _waitingForAction = false;
  _selectedKeyIndex = -1;
  
  if (_currentKeys!.isNotEmpty) {
    _currentOutputStream!.writeln(cyan.wrap("Type a number to select another key, 'l' to relist, or 'q' to quit."));
  }
  
  return true;
}

void _handleViewKey(AtKey key) async {
  try {
    final value = await get(_currentAtClient!, atKeyStr: key.toString());
    if (value != null) {
      _currentOutputStream!.writeln(green.wrap("Value:"));
      _currentOutputStream!.writeln(value);
      
      // Try to format as JSON if it's valid JSON
      try {
        final jsonValue = jsonDecode(value);
        _currentOutputStream!.writeln(cyan.wrap("\nFormatted JSON:"));
        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        _currentOutputStream!.writeln(encoder.convert(jsonValue));
      } catch (e) {
        // Not JSON, that's fine
      }
    } else {
      _currentOutputStream!.writeln(lightYellow.wrap("Key has no value"));
    }
  } catch (e) {
    _currentOutputStream!.writeln(red.wrap("Error getting value: $e"));
  }
}

void _handleDeleteKey(AtKey key, int index) async {
  try {
    final success = await delete(_currentAtClient!, atKeyStr: key.toString());
    if (success) {
      _currentOutputStream!.writeln(green.wrap("Successfully deleted: ${key.toString()}"));
      _currentKeys!.removeAt(index);
      
      if (_currentKeys!.isEmpty) {
        _currentOutputStream!.writeln(lightYellow.wrap("No more keys. Exiting interactive mode."));
        _exitInteractiveMode();
        return;
      }
      
      _showKeyList();
    } else {
      _currentOutputStream!.writeln(red.wrap("Failed to delete key"));
    }
  } catch (e) {
    _currentOutputStream!.writeln(red.wrap("Error deleting key: $e"));
  }
}

void _showKeyList() {
  if (_currentKeys == null || _currentOutputStream == null) return;
  
  _currentOutputStream!.writeln(green.wrap("\nFound ${_currentKeys!.length} key(s):"));
  _currentOutputStream!.writeln("${'#'.padRight(5)} | Key");
  _currentOutputStream!.writeln("${'─' * 5}─┼─${'─' * 50}");
  
  for (int i = 0; i < _currentKeys!.length; i++) {
    final indexStr = (i + 1).toString().padRight(5);
    _currentOutputStream!.writeln("$indexStr | ${_currentKeys![i].toString()}");
  }
  
  _currentOutputStream!.writeln(cyan.wrap("\nType a number to select a key, 'l' to relist, or 'q' to quit."));
}

void _exitInteractiveMode() {
  _inInteractiveMode = false;
  _waitingForAction = false;
  _currentKeys = null;
  _currentAtClient = null;
  _currentOutputStream = null;
  _selectedKeyIndex = -1;
}

bool get isInInteractiveMode => _inInteractiveMode;
bool get isWaitingForAction => _waitingForAction;


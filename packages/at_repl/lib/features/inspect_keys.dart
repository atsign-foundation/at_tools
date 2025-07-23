
import 'dart:io';
import 'dart:convert';
import 'package:at_client/at_client.dart';
import 'package:io/ansi.dart';
import '../interactive_session.dart';
import 'get.dart';
import 'delete.dart';

class InspectKeysResult {
  final List<AtKey> atKeys;
  final String regex;
  final bool shouldEnterInteractiveMode;

  InspectKeysResult(this.atKeys, this.regex, this.shouldEnterInteractiveMode);
}

class InspectKeysSession implements InteractiveSession {
  final List<AtKey> _keys;
  final AtClient _atClient;
  final IOSink _outputStream;
  bool _isActive = true;
  bool _waitingForAction = false;
  int _selectedKeyIndex = -1;

  InspectKeysSession(this._keys, this._atClient, this._outputStream) {
    _showKeyList();
    _outputStream.writeln(cyan.wrap("\nEntering interactive mode. Type a number to select a key, 'l' to relist, or 'q' to quit."));
  }

  @override
  bool handleInput(String input) {
    if (!_isActive) return false;
    
    input = input.trim();
    
    if (input.toLowerCase() == 'q' || input.toLowerCase() == 'quit') {
      _outputStream.writeln(green.wrap("Exiting interactive mode"));
      exit();
      return false;
    }
    
    if (_waitingForAction) {
      return _handleActionInput(input);
    }
    
    if (input.toLowerCase() == 'l' || input.toLowerCase() == 'list') {
      _showKeyList();
      return true;
    }
    
    final index = int.tryParse(input);
    if (index == null || index < 1 || index > _keys.length) {
      _outputStream.writeln(red.wrap("Invalid selection. Enter a number 1-${_keys.length}, 'l' to relist, or 'q' to quit."));
      return true;
    }
    
    final selectedKey = _keys[index - 1];
    _outputStream.writeln(green.wrap("Selected: ${selectedKey.toString()}"));
    _outputStream.writeln(cyan.wrap("Enter 'v' to view or 'd' to delete:"));
    
    _waitingForAction = true;
    _selectedKeyIndex = index - 1;
    
    return true;
  }

  bool _handleActionInput(String input) {
    final action = input.trim().toLowerCase();
    final selectedKey = _keys[_selectedKeyIndex];
    
    if (action == 'v') {
      _handleViewKey(selectedKey);
    } else if (action == 'd') {
      _handleDeleteKey(selectedKey, _selectedKeyIndex);
    } else {
      _outputStream.writeln(red.wrap("Invalid action. Enter 'v' to view or 'd' to delete."));
      return true;
    }
    
    _waitingForAction = false;
    _selectedKeyIndex = -1;
    
    if (_keys.isNotEmpty) {
      _outputStream.writeln(cyan.wrap("Type a number to select another key, 'l' to relist, or 'q' to quit."));
    }
    
    return true;
  }

  void _handleViewKey(AtKey key) async {
    try {
      final value = await get(_atClient, atKeyStr: key.toString());
      if (value != null) {
        _outputStream.writeln(green.wrap("Value:"));
        _outputStream.writeln(value);
        
        // Try to format as JSON if it's valid JSON
        try {
          final jsonValue = jsonDecode(value);
          _outputStream.writeln(cyan.wrap("\nFormatted JSON:"));
          const JsonEncoder encoder = JsonEncoder.withIndent('  ');
          _outputStream.writeln(encoder.convert(jsonValue));
        } catch (e) {
          // Not JSON, that's fine
        }
      } else {
        _outputStream.writeln(lightYellow.wrap("Key has no value"));
      }
    } catch (e) {
      _outputStream.writeln(red.wrap("Error getting value: $e"));
    }
  }

  void _handleDeleteKey(AtKey key, int index) async {
    try {
      final success = await delete(_atClient, atKeyStr: key.toString());
      if (success) {
        _outputStream.writeln(green.wrap("Successfully deleted: ${key.toString()}"));
        _keys.removeAt(index);
        
        if (_keys.isEmpty) {
          _outputStream.writeln(lightYellow.wrap("No more keys. Exiting interactive mode."));
          exit();
          return;
        }
        
        _showKeyList();
      } else {
        _outputStream.writeln(red.wrap("Failed to delete key"));
      }
    } catch (e) {
      _outputStream.writeln(red.wrap("Error deleting key: $e"));
    }
  }

  void _showKeyList() {
    _outputStream.writeln(green.wrap("\nFound ${_keys.length} key(s):"));
    _outputStream.writeln("${'#'.padRight(5)} | Key");
    _outputStream.writeln("${'─' * 5}─┼─${'─' * 50}");
    
    for (int i = 0; i < _keys.length; i++) {
      final indexStr = (i + 1).toString().padRight(5);
      _outputStream.writeln("$indexStr | ${_keys[i].toString()}");
    }
  }

  @override
  String getPrompt() {
    if (_waitingForAction) {
      return "action> ";
    }
    return "inspect_keys> ";
  }

  @override
  bool get isActive => _isActive;

  @override
  void exit() {
    _isActive = false;
    _waitingForAction = false;
    _selectedKeyIndex = -1;
  }
}


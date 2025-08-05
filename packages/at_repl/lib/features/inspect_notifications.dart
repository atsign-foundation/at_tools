import 'dart:io';
import 'dart:convert';
import 'package:io/ansi.dart';
import '../interactive_session.dart';

class InspectNotificationsSession implements InteractiveSession {
  final List<Map<String, dynamic>> _notifications;
  final IOSink _outputStream;
  final Future<String> Function(String) _executeCommand;
  bool _isActive = true;
  bool _waitingForAction = false;
  int _selectedNotificationIndex = -1;

  InspectNotificationsSession(this._notifications, this._outputStream, this._executeCommand) {
    _showNotificationList();
    _outputStream.writeln(cyan.wrap("\nEntering interactive mode. Type a number to select a notification, 'l' to relist, or 'q' to quit."));
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
      _showNotificationList();
      return true;
    }
    
    final index = int.tryParse(input);
    if (index == null || index < 1 || index > _notifications.length) {
      _outputStream.writeln(red.wrap("Invalid selection. Enter a number 1-${_notifications.length}, 'l' to relist, or 'q' to quit."));
      return true;
    }
    
    final selectedNotification = _notifications[index - 1];
    final notificationId = selectedNotification['id'];
    _outputStream.writeln(green.wrap("Selected notification ID: $notificationId"));
    _outputStream.writeln(cyan.wrap("Enter 'v' to view details or 'd' to delete:"));
    
    _waitingForAction = true;
    _selectedNotificationIndex = index - 1;
    
    return true;
  }

  bool _handleActionInput(String input) {
    final action = input.trim().toLowerCase();
    final selectedNotification = _notifications[_selectedNotificationIndex];
    
    if (action == 'v') {
      _handleViewNotification(selectedNotification);
    } else if (action == 'd') {
      _handleDeleteNotification(selectedNotification, _selectedNotificationIndex);
    } else {
      _outputStream.writeln(red.wrap("Invalid action. Enter 'v' to view or 'd' to delete."));
      return true;
    }
    
    _waitingForAction = false;
    _selectedNotificationIndex = -1;
    
    if (_notifications.isNotEmpty) {
      _outputStream.writeln(cyan.wrap("Type a number to select another notification, 'l' to relist, or 'q' to quit."));
    }
    
    return true;
  }

  void _handleViewNotification(Map<String, dynamic> notification) {
    _outputStream.writeln(green.wrap("Notification details:"));
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    _outputStream.writeln(encoder.convert(notification));
  }

  void _handleDeleteNotification(Map<String, dynamic> notification, int index) async {
    final notificationId = notification['id'];
    try {
      await _executeCommand("notify:remove:$notificationId\n");
      _outputStream.writeln(green.wrap("Successfully deleted notification: $notificationId"));
      _notifications.removeAt(index);
      
      if (_notifications.isEmpty) {
        _outputStream.writeln(lightYellow.wrap("No more notifications. Exiting interactive mode."));
        exit();
        return;
      }
      
      _showNotificationList();
    } catch (e) {
      _outputStream.writeln(red.wrap("Error deleting notification: $e"));
    }
  }

  void _showNotificationList() {
    _outputStream.writeln(green.wrap("\nFound ${_notifications.length} notification(s):"));
    _showNotificationTable(_notifications, _outputStream);
  }

  void _showNotificationTable(List<Map<String, dynamic>> notifications, IOSink outputStream) {
    outputStream.writeln("${'#'.padRight(5)} | ${'ID'.padRight(36)} | ${'From'.padRight(15)} | ${'To'.padRight(15)} | Timestamp");
    outputStream.writeln("${'─' * 5}─┼─${'─' * 36}─┼─${'─' * 15}─┼─${'─' * 15}─┼─${'─' * 20}");
    
    for (int i = 0; i < notifications.length; i++) {
      final indexStr = (i + 1).toString().padRight(5);
      final notification = notifications[i];
      final id = (notification['id'] ?? 'Unknown').toString().padRight(36);
      final from = (notification['from'] ?? 'Unknown').toString().padRight(15);
      final to = (notification['to'] ?? 'Unknown').toString().padRight(15);
      
      // Convert epochMillis to readable timestamp
      String timestamp = 'Unknown';
      if (notification['epochMillis'] != null) {
        try {
          final epochMillis = notification['epochMillis'] as int;
          final dateTime = DateTime.fromMillisecondsSinceEpoch(epochMillis);
          timestamp = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
        } catch (e) {
          timestamp = 'Invalid';
        }
      }
      
      outputStream.writeln("$indexStr | $id | $from | $to | $timestamp");
    }
    
    outputStream.writeln(cyan.wrap("\nType a number to select a notification, 'l' to relist, or 'q' to quit."));
  }

  @override
  String getPrompt() {
    if (_waitingForAction) {
      return "action> ";
    }
    return "inspect_notifications> ";
  }

  @override
  bool get isActive => _isActive;

  @override
  void exit() {
    _isActive = false;
    _waitingForAction = false;
    _selectedNotificationIndex = -1;
  }
}

List<Map<String, dynamic>> parseNotifications(String response) {
  try {
    // The response should be a JSON array
    final decoded = jsonDecode(response.trim());
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  } catch (e) {
    // Try parsing line by line as fallback
    final notifications = <Map<String, dynamic>>[];
    final lines = response.split('\n');
    
    for (final line in lines) {
      if (line.trim().isEmpty || line.startsWith('data:')) continue;
      
      try {
        final decoded = jsonDecode(line);
        if (decoded is Map<String, dynamic>) {
          notifications.add(decoded);
        }
      } catch (e) {
        // Skip lines that can't be parsed as JSON
      }
    }
    
    return notifications;
  }
}

// All interactive functionality has been moved to InspectNotificationsSession
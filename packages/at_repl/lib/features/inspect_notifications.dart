
import 'dart:io';
import 'dart:convert';
import 'package:at_client/at_client.dart';
import 'package:io/ansi.dart';

class InspectNotificationsResult {
  final List<dynamic> notifications; // list of notification objects
  final bool shouldEnterInteractiveMode;

  InspectNotificationsResult(this.notifications, this.shouldEnterInteractiveMode);
}

// Global state for notification interactive mode
List<Map<String, dynamic>>? _currentNotifications;
IOSink? _currentNotificationOutputStream;
Future<String> Function(String)? _currentExecuteCommand;
bool _inNotificationInteractiveMode = false;
bool _waitingForNotificationAction = false;
int _selectedNotificationIndex = -1;

void handleInspectNotifications(String input, AtClient atClient, IOSink outputStream, {required Future<String> Function(String) executeCommand}) async {
  try {
    outputStream.writeln(cyan.wrap("Fetching notifications..."));
    
    final response = await executeCommand("notify:list\n");
    // remove data: prefix if present
    final cleanedResponse = response.replaceAll(RegExp(r'^data:\s*'), '');
    if (cleanedResponse.isEmpty || cleanedResponse == '[]') {
      outputStream.writeln(lightYellow.wrap("No notifications found"));
      return;
    }
    // Parse the response as JSON
    final notifications = _parseNotifications(cleanedResponse);

    if (notifications.isEmpty) {
      outputStream.writeln(lightYellow.wrap("No notifications found"));
      return;
    }
    
    outputStream.writeln(green.wrap("\nFound ${notifications.length} notification(s):"));
    _showNotificationTable(notifications, outputStream);
    
    outputStream.writeln(cyan.wrap("\nEntering interactive mode. Type a number to select a notification, 'l' to relist, or 'q' to quit."));
    
    // Set up interactive mode state
    _currentNotifications = notifications;
    _currentNotificationOutputStream = outputStream;
    _currentExecuteCommand = executeCommand;
    _inNotificationInteractiveMode = true;
    
  } catch (e) {
    outputStream.writeln(red.wrap("Error inspecting notifications: $e"));
  }
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
}

List<Map<String, dynamic>> _parseNotifications(String response) {
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

bool handleNotificationInteractiveInput(String input) {
  if (!_inNotificationInteractiveMode || _currentNotifications == null) return false;
  
  input = input.trim();
  
  if (input.toLowerCase() == 'q' || input.toLowerCase() == 'quit') {
    _currentNotificationOutputStream!.writeln(green.wrap("Exiting interactive mode"));
    _exitNotificationInteractiveMode();
    return true;
  }
  
  if (input.toLowerCase() == 'l' || input.toLowerCase() == 'list') {
    _showNotificationList();
    return true;
  }
  
  final index = int.tryParse(input);
  if (index == null || index < 1 || index > _currentNotifications!.length) {
    _currentNotificationOutputStream!.writeln(red.wrap("Invalid selection. Enter a number 1-${_currentNotifications!.length}, 'l' to relist, or 'q' to quit."));
    return true;
  }
  
  final selectedNotification = _currentNotifications![index - 1];
  final notificationId = selectedNotification['id'];
  _currentNotificationOutputStream!.writeln(green.wrap("Selected notification ID: $notificationId"));
  _currentNotificationOutputStream!.writeln(cyan.wrap("Enter 'v' to view details or 'd' to delete:"));
  
  // Set up state for action input
  _waitingForNotificationAction = true;
  _selectedNotificationIndex = index - 1;
  
  return true;
}

bool handleNotificationActionInput(String input) {
  if (!_waitingForNotificationAction || _currentNotifications == null) return false;
  
  final action = input.trim().toLowerCase();
  final selectedNotification = _currentNotifications![_selectedNotificationIndex];
  
  if (action == 'v') {
    _handleViewNotification(selectedNotification);
  } else if (action == 'd') {
    _handleDeleteNotification(selectedNotification, _selectedNotificationIndex);
  } else {
    _currentNotificationOutputStream!.writeln(red.wrap("Invalid action. Enter 'v' to view or 'd' to delete."));
    return true;
  }
  
  _waitingForNotificationAction = false;
  _selectedNotificationIndex = -1;
  
  if (_currentNotifications!.isNotEmpty) {
    _currentNotificationOutputStream!.writeln(cyan.wrap("Type a number to select another notification, 'l' to relist, or 'q' to quit."));
  }
  
  return true;
}

void _handleViewNotification(Map<String, dynamic> notification) {
  _currentNotificationOutputStream!.writeln(green.wrap("Notification details:"));
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  _currentNotificationOutputStream!.writeln(encoder.convert(notification));
}

void _handleDeleteNotification(Map<String, dynamic> notification, int index) async {
  final notificationId = notification['id'];
  try {
    await _currentExecuteCommand!("notify:remove:$notificationId\n");
    _currentNotificationOutputStream!.writeln(green.wrap("Successfully deleted notification: $notificationId"));
    _currentNotifications!.removeAt(index);
    
    if (_currentNotifications!.isEmpty) {
      _currentNotificationOutputStream!.writeln(lightYellow.wrap("No more notifications. Exiting interactive mode."));
      _exitNotificationInteractiveMode();
      return;
    }
    
    _showNotificationList();
  } catch (e) {
    _currentNotificationOutputStream!.writeln(red.wrap("Error deleting notification: $e"));
  }
}

void _showNotificationList() {
  if (_currentNotifications == null || _currentNotificationOutputStream == null) return;
  
  _currentNotificationOutputStream!.writeln(green.wrap("\nFound ${_currentNotifications!.length} notification(s):"));
  _showNotificationTable(_currentNotifications!, _currentNotificationOutputStream!);
  _currentNotificationOutputStream!.writeln(cyan.wrap("\nType a number to select a notification, 'l' to relist, or 'q' to quit."));
}

void _exitNotificationInteractiveMode() {
  _inNotificationInteractiveMode = false;
  _waitingForNotificationAction = false;
  _currentNotifications = null;
  _currentNotificationOutputStream = null;
  _currentExecuteCommand = null;
  _selectedNotificationIndex = -1;
}

bool get isInNotificationInteractiveMode => _inNotificationInteractiveMode;
bool get isWaitingForNotificationAction => _waitingForNotificationAction;
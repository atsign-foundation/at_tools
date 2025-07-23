
import 'dart:io';
import 'dart:convert';
import 'package:at_client/at_client.dart';
import 'package:io/ansi.dart';

class InspectNotificationsResult {
  final List<dynamic> notifications; // list of notification objects
  final bool shouldEnterInteractiveMode;

  InspectNotificationsResult(this.notifications, this.shouldEnterInteractiveMode);
}

void handleInspectNotifications(String input, AtClient atClient, IOSink outputStream, {required Future<String> Function(String) executeCommand}) async {
  try {
    outputStream.writeln(cyan.wrap("Fetching notifications..."));
    
    final response = await executeCommand("notify:list\n");
    final notifications = _parseNotifications(response);
    
    if (notifications.isEmpty) {
      outputStream.writeln(lightYellow.wrap("No notifications found"));
      return;
    }
    
    outputStream.writeln(green.wrap("\nFound ${notifications.length} notification(s):"));
    outputStream.writeln("${'#'.padRight(5)} | ${'ID'.padRight(20)} | ${'From'.padRight(15)} | To");
    outputStream.writeln("${'─' * 5}─┼─${'─' * 20}─┼─${'─' * 15}─┼─${'─' * 15}");
    
    for (int i = 0; i < notifications.length; i++) {
      final indexStr = (i + 1).toString().padRight(5);
      final notification = notifications[i];
      final id = (notification['id'] ?? 'Unknown').toString().padRight(20);
      final from = (notification['from'] ?? 'Unknown').toString().padRight(15);
      final to = (notification['to'] ?? 'Unknown').toString();
      outputStream.writeln("$indexStr | $id | $from | $to");
    }
    
    outputStream.writeln(cyan.wrap("\nEntering interactive mode. Type a number to select a notification, 'q' to quit."));
    
    await _enterNotificationInteractiveMode(notifications, outputStream, executeCommand);
    
  } catch (e) {
    outputStream.writeln(red.wrap("Error inspecting notifications: $e"));
  }
}

List<Map<String, dynamic>> _parseNotifications(String response) {
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

Future<void> _enterNotificationInteractiveMode(List<Map<String, dynamic>> notifications, IOSink outputStream, Future<String> Function(String) executeCommand) async {
  final stdinStream = stdin.transform(utf8.decoder).transform(const LineSplitter());
  
  await for (String input in stdinStream) {
    input = input.trim();
    
    if (input.isEmpty) continue;
    
    if (input.toLowerCase() == 'q' || input.toLowerCase() == 'quit') {
      outputStream.writeln(green.wrap("Exiting interactive mode"));
      break;
    }
    
    final index = int.tryParse(input);
    if (index == null || index < 1 || index > notifications.length) {
      outputStream.writeln(red.wrap("Invalid selection. Enter a number 1-${notifications.length}, or 'q' to quit."));
      continue;
    }
    
    final selectedNotification = notifications[index - 1];
    final notificationId = selectedNotification['id'];
    outputStream.writeln(green.wrap("Selected notification ID: $notificationId"));
    outputStream.writeln("Enter 'v' to view details or 'd' to delete:");
    
    final actionInput = await stdinStream.first;
    final action = actionInput.trim().toLowerCase();
    
    if (action == 'v') {
      outputStream.writeln(green.wrap("Notification details:"));
      outputStream.writeln(jsonEncode(selectedNotification));
    } else if (action == 'd') {
      try {
        await executeCommand("notify:remove:$notificationId\n");
        outputStream.writeln(green.wrap("Successfully deleted notification: $notificationId"));
        notifications.removeAt(index - 1);
        
        if (notifications.isEmpty) {
          outputStream.writeln(lightYellow.wrap("No more notifications. Exiting interactive mode."));
          break;
        }
        
        outputStream.writeln(cyan.wrap("\nUpdated notification list:"));
        outputStream.writeln("${'#'.padRight(5)} | ${'ID'.padRight(20)} | ${'From'.padRight(15)} | To");
        outputStream.writeln("${'─' * 5}─┼─${'─' * 20}─┼─${'─' * 15}─┼─${'─' * 15}");
        
        for (int i = 0; i < notifications.length; i++) {
          final indexStr = (i + 1).toString().padRight(5);
          final notification = notifications[i];
          final id = (notification['id'] ?? 'Unknown').toString().padRight(20);
          final from = (notification['from'] ?? 'Unknown').toString().padRight(15);
          final to = (notification['to'] ?? 'Unknown').toString();
          outputStream.writeln("$indexStr | $id | $from | $to");
        }
      } catch (e) {
        outputStream.writeln(red.wrap("Error deleting notification: $e"));
      }
    } else {
      outputStream.writeln(red.wrap("Invalid action. Enter 'v' to view or 'd' to delete."));
    }
    
    outputStream.writeln(cyan.wrap("\nType a number to select another notification, or 'q' to quit."));
  }
}
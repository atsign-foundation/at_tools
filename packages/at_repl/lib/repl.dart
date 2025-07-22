import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:at_client/at_client.dart';
import 'package:at_onboarding_cli/at_onboarding_cli.dart';
import 'package:io/ansi.dart';

// /inspect command provides interactive key browsing with default filtering

class REPL {
  final String rootDomain;
  final int rootPort;
  final String atSign;
  late AtClient atClient;

  REPL({required this.rootDomain, required this.rootPort, required this.atSign}) {
    Future<bool> success = _pkamAuth(rootDomain, rootPort, atSign);
    success.then((value) {
      if (!value) {
        stdout.writeln(red.wrap("Authentication failed. Exiting..."));
        exit(1);
      }
    }).catchError((error) {
      stdout.writeln(red.wrap("Error during authentication: $error"));
      exit(1);
    });
  }

  /// This function is for executing protocol verbs
  /// Make sure that you add a \n at the end of the command so that you can get a return string back
  Future<String> executeCommand(String command) async {
    final RemoteSecondary rs = atClient.getRemoteSecondary()!;
    final String? response = (await rs.executeCommand(command, auth: true));
    if (response == null) {
      throw Exception(
          'Result is null for some reason after executing command: $command');
    }
    return response;
  }


  ///enters inspect mode for interactive key browsing
  Future<InspectResult> inspect(List<String> args) async {
    stdout.writeln(lightGreen.wrap("Entering inspect mode..."));
    stdout.writeln(lightGreen.wrap("Scanning for AtKeys..."));

    String interactiveRegex = (args.length > 1
        ? args[1]
        : r"^(?!.*shared_key)(?!.*publickey)(?!.*signing_privatekey).*$");
    var allAtKeys = await atClient.getAtKeys();
    var interactiveAtKeys = await atClient.getAtKeys(regex: interactiveRegex);

    if (interactiveAtKeys.isEmpty) {
      if (interactiveRegex.isNotEmpty) {
        stdout.writeln(
            yellow.wrap("No AtKeys found matching regex '$interactiveRegex'."));
      } else {
        stdout.writeln(yellow.wrap("No AtKeys found."));
      }
      return InspectResult([], "", false);
    }

    if (interactiveRegex.isNotEmpty) {
      stdout.writeln(lightGreen.wrap(
          "${interactiveAtKeys.length}/${allAtKeys.length} keys shown with regex '$interactiveRegex'"));
    } else {
      stdout.writeln(
          lightGreen.wrap("Found ${interactiveAtKeys.length} AtKeys:"));
    }

    for (int i = 0; i < interactiveAtKeys.length; i++) {
      stdout.writeln("${i + 1}. ${interactiveAtKeys[i].toString()}");
    }

    stdout.writeln(lightBlue.wrap(
        "\nEnter the number of the AtKey you want to interact with (or 'q' to quit):"));
    return InspectResult(interactiveAtKeys, interactiveRegex, true);
  }

  ///starts monitor mode with optional regex filter
  Future<StreamSubscription<AtNotification>?> monitor(List<String> args) async {
    String defaultRegex = "^(?!.*statsNotification).*";
    // use regex if provided, otherwise use default
    String monitorRegex = args.length > 1 ? args[1] : defaultRegex;
    stdout.writeln(
        lightGreen.wrap("Starting monitor mode with regex: '$monitorRegex'"));
    stdout.writeln(lightGreen.wrap(
        "Monitoring for notifications... (use 'q', 'quit', or 'stop' to exit)"));

    try {
      // Use the notification service to subscribe to notifications
      var notificationService = atClient.notificationService;

      // Subscribe to notification stream
      StreamSubscription<AtNotification> subscription = notificationService
          .subscribe(regex: monitorRegex, shouldDecrypt: true)
          .listen((notification) {
        var timestamp = DateTime.now().toString();
        stdout.writeln(lightCyan.wrap("[$timestamp] $notification"));
        if (notification.value != null) {
          stdout.writeln(lightCyan.wrap("\nValue: ${notification.value}"));
          // Try to parse and pretty-print if it's JSON
          try {
            var jsonValue = jsonDecode(notification.value.toString());
            var prettyJson = JsonEncoder.withIndent('  ').convert(jsonValue);
            stdout.writeln(lightCyan.wrap("\nPretty JSON Value:\n$prettyJson"));
          } catch (e) {
            // Not JSON, just print the raw value
          }
        }
      }, onError: (error) {
        stdout.writeln(red.wrap("Monitor error: ${error.toString()}"));
      }, onDone: () {
        stdout.writeln(yellow.wrap("Monitor stream closed."));
      });

      stdout.writeln(yellow
          .wrap("Monitor mode active. Type 'q', 'quit', or 'stop' to exit."));
      return subscription;
    } catch (e) {
      stdout.writeln(red.wrap("Error starting monitor: ${e.toString()}"));
      return null;
    }
  }

  ///enters notification inspect mode for interactive notification management
  Future<NotifyInspectResult> inspectNotify() async {
    stdout.writeln(lightGreen.wrap("Entering notification inspect mode..."));
    stdout.writeln(lightGreen.wrap("Fetching notifications..."));

    try {
      // Execute raw notify:list command
      String response = await executeCommand('notify:list\n');

      if (response.startsWith('data:')) {
        String jsonData = response.substring(5); // Remove 'data:' prefix
        List<dynamic> notifications = jsonDecode(jsonData);

        if (notifications.isEmpty) {
          stdout.writeln(yellow.wrap("No notifications found."));
          return NotifyInspectResult([], false);
        }

        // Display notifications table
        _displayNotificationsTable(notifications);

        stdout.writeln(lightBlue.wrap(
            "\nEnter notification index (1-${notifications.length}), 'l' to refresh list, or 'q' to quit:"));
        return NotifyInspectResult(notifications, true);
      } else {
        stdout.writeln(red.wrap("Unexpected response format: $response"));
        return NotifyInspectResult([], false);
      }
    } catch (e) {
      stdout.writeln(red.wrap("Error fetching notifications: ${e.toString()}"));
      return NotifyInspectResult([], false);
    }
  }

  void _displayNotificationsTable(List<dynamic> notifications) {
    stdout.writeln(lightCyan.wrap(
        "\n${'#'.padRight(3)} ${'From'.padRight(20)} ${'To'.padRight(20)} ${'Date'.padRight(20)} ${'ID'.padRight(36)}"));
    stdout.writeln(lightCyan
        .wrap("${'─' * 3} ${'─' * 20} ${'─' * 20} ${'─' * 20} ${'─' * 36}"));

    for (int i = 0; i < notifications.length; i++) {
      var notification = notifications[i];
      String from = notification['from'] ?? 'N/A';
      String to = notification['to'] ?? 'N/A';
      String id = notification['id'] ?? 'N/A';

      // Convert epoch millis to readable date
      String date = 'N/A';
      if (notification['epochMillis'] != null) {
        try {
          int epochMillis = notification['epochMillis'];
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epochMillis);
          date =
              '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
        } catch (e) {
          date = 'Invalid';
        }
      }

      stdout.writeln(
          "${(i + 1).toString().padRight(3)} ${from.padRight(20)} ${to.padRight(20)} ${date.padRight(20)} ${id.padRight(36)}");
    }
  }

  ///handles notification management actions (view, delete, list)
  Future<bool> handleNotifyAction(
      String action, List<dynamic> notifications, int index) async {
    if (index < 1 || index > notifications.length) {
      stdout.writeln(red.wrap(
          "Invalid notification index. Please enter a number between 1 and ${notifications.length}."));
      return false;
    }

    var notification = notifications[index - 1];
    String notificationId = notification['id'] ?? '';

    switch (action.toLowerCase()) {
      case 'v':
        // View notification
        stdout.writeln(lightCyan.wrap("\n--- Notification Details ---"));
        stdout.writeln(jsonEncode(notification));
        stdout.writeln(lightCyan.wrap("--- End Details ---\n"));
        return false;

      case 'd':
        // Delete notification
        if (notificationId.isEmpty) {
          stdout.writeln(red.wrap("Cannot delete notification: missing ID"));
          return false;
        }

        try {
          String deleteResponse =
              await executeCommand('notify:remove:$notificationId');
          stdout.writeln(lightGreen
              .wrap("Notification deleted successfully: $deleteResponse"));
          return true; // Return true to refresh the list
        } catch (e) {
          stdout.writeln(
              red.wrap("Error deleting notification: ${e.toString()}"));
          return false;
        }

      default:
        stdout.writeln(
            red.wrap("Invalid action. Use 'v' to view or 'd' to delete."));
        return false;
    }
  }

  Future<bool> _pkamAuth(final String rootDomain, final int rootPort, final String atSign) async {
    AtOnboardingPreference pref = AtOnboardingPreference()
      ..namespace = 'at_repl'
      ..rootDomain = rootDomain
      ..rootPort = rootPort
      ;
    AtOnboardingService service = AtOnboardingServiceImpl(atSign, pref);
    bool success = await service.authenticate();
    if(success) {
      atClient = service.atClient!;
      return true;
    }
    return success;
  }
}

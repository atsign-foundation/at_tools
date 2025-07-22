import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:at_client/at_client.dart';
import 'package:at_onboarding_cli/at_onboarding_cli.dart';
import 'package:io/ansi.dart';

// /inspect command provides interactive key browsing with default filtering

class REPL {
  ///User's atSign
  final String atSign;
  final String namespace = 'at_repl';

  ///defaults to root.atsign.org:64 which is the atDirectory
  final String rootUrl;

  ///is null until the REPL has authenticated
  late AtOnboardingService _atOnboardingService;
  REPL(this.atSign, {this.rootUrl = 'root.atsign.org:64'});

  AtClient get atClient => AtClientManager.getInstance().atClient;

  ///authenticates onboardingService
  Future<bool> authenticate() {
    AtOnboardingPreference pref = AtOnboardingPreference()
      ..namespace = 'at_repl'
      ..rootDomain = rootUrl.split(':')[0]
      ..rootPort = int.parse(rootUrl.split(':')[1]);

    _atOnboardingService = AtOnboardingServiceImpl(atSign, pref);
    return _atOnboardingService.authenticate();
  }

  /// executes protocol verbs
  Future<String> executeCommand(String command) async {
    late String result;
    if (_atOnboardingService.atClient == null) {
      throw Exception('AtClient is null for some reason...');
    }
    if (_atOnboardingService.atClient!.getRemoteSecondary() == null) {
      throw Exception('RemoteSecondary is null for some reason...');
    }
    final RemoteSecondary rs = atClient.getRemoteSecondary()!;

    final String? response = (await rs.executeCommand(command, auth: true));

    if (response == null) {
      throw Exception(
          'Result is null for some reason after executing command: $command');
    }

    result = response;

    return result;
  }

  ///gets the value of desired key
  Future<String> getKey(List<String> args) async {
    if (args.length != 2) {
      throw Exception("Please enter a record ID - e.g. /get test@alice");
    }
    String id = args[1];
    RegExp encryptedSharedKeyMatcher =
        RegExp(r'^shared_key\..+@.+|@.+:shared_key@.+');
    if (id.contains(encryptedSharedKeyMatcher)) {
      throw AtKeyException("The given key is a symmetric shared key.");
    }

    AtValue atValue = await atClient.get(AtKey.fromString(id));
    return " => ${atValue.value}";
  }

  ///puts the atKey to secondary server
  Future<String> put(List<String> args, bool enforceNamespace) async {
    if (args.length != 3) {
      throw Exception(
          "Please enter a record ID and a value - e.g. /put test@alice value");
    }
    if (!enforceNamespace) {
      if (!args[1].contains('.')) {
        args[1] =
            "${args[1].substring(0, args[1].indexOf('@'))}.$namespace${args[1].substring(args[1].indexOf('@'))}";
      }
    }
    String id = args[1];
    String value = args[2];
    RegExp encryptedSharedKeyMatcher =
        RegExp(r'^shared_key\..+@.+|@.+:shared_key@.+');
    if (id.contains(encryptedSharedKeyMatcher)) {
      throw AtKeyException("The given key is a symmetric shared key.");
    }
    PutRequestOptions pro = PutRequestOptions()
      ..useRemoteAtServer = true;
    dynamic result = await atClient.put(AtKey.fromString(id), value, putRequestOptions: pro);
    return " key creation result - $result";
  }

  ///deletes atKey from secondary server
  Future<String> delete(List<String> args) async {
    if (args.length != 2) {
      throw Exception("Please enter a record ID - e.g. /delete test@alice");
    }
    String id = args[1];
    DeleteRequestOptions dro = DeleteRequestOptions()..useRemoteAtServer=true;
    dynamic response = await atClient.delete(AtKey.fromString(id), deleteRequestOptions: dro);
    return (" => $response");
  }

  ///scans for atKeys with optional regex filter
  Future<void> scan(List<String> args) async {
    String regex = (args.length > 1 ? args[1] : "");
    var values = await atClient.getAtKeys(regex: regex);
    stdout.writeln(lightCyan.wrap(" => $values"));
  }

  ///enters inspect mode for interactive key browsing
  Future<InspectResult> inspect(List<String> args) async {
    stdout.writeln(lightGreen.wrap("Entering inspect mode..."));
    stdout.writeln(lightGreen.wrap("Scanning for AtKeys..."));
    
    String interactiveRegex = (args.length > 1 ? args[1] : r"^(?!.*shared_key)(?!.*publickey)(?!.*signing_privatekey).*$");
    var allAtKeys = await atClient.getAtKeys();
    var interactiveAtKeys = await atClient.getAtKeys(regex: interactiveRegex);
    
    if (interactiveAtKeys.isEmpty) {
      if (interactiveRegex.isNotEmpty) {
        stdout.writeln(yellow.wrap("No AtKeys found matching regex '$interactiveRegex'."));
      } else {
        stdout.writeln(yellow.wrap("No AtKeys found."));
      }
      return InspectResult([], "", false);
    }
    
    if (interactiveRegex.isNotEmpty) {
      stdout.writeln(lightGreen.wrap("${interactiveAtKeys.length}/${allAtKeys.length} keys shown with regex '$interactiveRegex'"));
    } else {
      stdout.writeln(lightGreen.wrap("Found ${interactiveAtKeys.length} AtKeys:"));
    }
    
    for (int i = 0; i < interactiveAtKeys.length; i++) {
      stdout.writeln("${i + 1}. ${interactiveAtKeys[i].toString()}");
    }
    
    stdout.writeln(lightBlue.wrap("\nEnter the number of the AtKey you want to interact with (or 'q' to quit):"));
    return InspectResult(interactiveAtKeys, interactiveRegex, true);
  }

  ///starts monitor mode with optional regex filter
  Future<StreamSubscription<AtNotification>?> monitor(List<String> args) async {
    String defaultRegex = "^(?!.*statsNotification).*";
    String monitorRegex = (args.length > 1 ? args[1] : defaultRegex);
    stdout.writeln(lightGreen.wrap("Starting monitor mode with regex: '$monitorRegex'"));
    stdout.writeln(lightGreen.wrap("Monitoring for notifications... (use 'q', 'quit', or 'stop' to exit)"));
    
    try {
      // Use the notification service to subscribe to notifications
      var notificationService = atClient.notificationService;
      
      // Subscribe to notification stream
      StreamSubscription<AtNotification> subscription = notificationService.subscribe(regex: monitorRegex, shouldDecrypt: true).listen(
        (notification) {
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
        },
        onError: (error) {
          stdout.writeln(red.wrap("Monitor error: ${error.toString()}"));
        },
        onDone: () {
          stdout.writeln(yellow.wrap("Monitor stream closed."));
        }
      );
      
      stdout.writeln(yellow.wrap("Monitor mode active. Type 'q', 'quit', or 'stop' to exit."));
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
        
        stdout.writeln(lightBlue.wrap("\nEnter notification index (1-${notifications.length}), 'l' to refresh list, or 'q' to quit:"));
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
    stdout.writeln(lightCyan.wrap("\n${'#'.padRight(3)} ${'From'.padRight(20)} ${'To'.padRight(20)} ${'Date'.padRight(20)} ${'ID'.padRight(36)}"));
    stdout.writeln(lightCyan.wrap("${'─' * 3} ${'─' * 20} ${'─' * 20} ${'─' * 20} ${'─' * 36}"));
    
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
          date = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
        } catch (e) {
          date = 'Invalid';
        }
      }
      
      stdout.writeln("${(i + 1).toString().padRight(3)} ${from.padRight(20)} ${to.padRight(20)} ${date.padRight(20)} ${id.padRight(36)}");
    }
  }

  ///handles notification management actions (view, delete, list)
  Future<bool> handleNotifyAction(String action, List<dynamic> notifications, int index) async {
    if (index < 1 || index > notifications.length) {
      stdout.writeln(red.wrap("Invalid notification index. Please enter a number between 1 and ${notifications.length}."));
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
          String deleteResponse = await executeCommand('notify:remove:$notificationId');
          stdout.writeln(lightGreen.wrap("Notification deleted successfully: $deleteResponse"));
          return true; // Return true to refresh the list
        } catch (e) {
          stdout.writeln(red.wrap("Error deleting notification: ${e.toString()}"));
          return false;
        }
      
      default:
        stdout.writeln(red.wrap("Invalid action. Use 'v' to view or 'd' to delete."));
        return false;
    }
  }
}

class InspectResult {
  final List<AtKey> atKeys;
  final String regex;
  final bool shouldEnterInteractiveMode;
  
  InspectResult(this.atKeys, this.regex, this.shouldEnterInteractiveMode);
}

class NotifyInspectResult {
  final List<dynamic> notifications;
  final bool shouldEnterInteractiveMode;
  
  NotifyInspectResult(this.notifications, this.shouldEnterInteractiveMode);
}

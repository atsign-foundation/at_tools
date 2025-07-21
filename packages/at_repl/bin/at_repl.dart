import 'dart:convert';
import 'dart:async';
import 'package:at_utils/at_logger.dart';
import 'package:args/args.dart';
import 'package:at_client/at_client.dart';
import 'package:at_repl/src/at_repl.dart';
import 'dart:io';
import 'package:io/ansi.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:at_repl/src/version.dart' as version;
//make sure you cd to at_repl dir.
//cd packages\at_repl

// REPL ONLY REQUIRES AN ATSIGN OPTION
//EX.
//dart run at_repl -a @xavierlin0

//FULL REPL COMMAND
//dart run at_repl -a @xavierlin -r root.atsign.org:64 -v -n

Future<void> main(List<String> arguments) async {
  AtClient? atClient;
  String rootUrl = "";
  String atSign = "@chess69";
  bool verbose = false;
  bool enforceNamespace = false;
  AtSignLogger logger = AtSignLogger("repl");
  final ArgParser argParser = ArgParser()
    ..addOption(
      "atSign",
      abbr: 'a',
      mandatory: true,
    )
    ..addOption("rootUrl",
        abbr: 'r', mandatory: false, defaultsTo: "root.atsign.org:64")
    ..addFlag("verbose", abbr: 'v', defaultsTo: false)
    ..addFlag("enforceNamespace",
        abbr: 'n',
        defaultsTo: true,
        help:
            "specifically for /put, if false namespaces will automatically by placed.");

  final pubUpdater = PubUpdater();
  final upToDate = await pubUpdater.isUpToDate(
      packageName: "at_repl", currentVersion: version.packageVersion);
  if (!upToDate) {
    stdout.writeln(red.wrap("Package out of date, updating..."));
    await pubUpdater.update(packageName: 'at_repl');
    stdout.write(green.wrap("Updated."));
  }
  try {
    var results = argParser.parse(arguments);
    rootUrl = results["rootUrl"];
    atSign = results["atSign"];
    verbose = results["verbose"];
    enforceNamespace = results["enforceNamespace"];
    stdout
        .writeln("Looking up secondary server address for $atSign on $rootUrl");
  } catch (e) {
    stdout.writeln(red.wrap('Invalid arguments. Usage:\n${argParser.usage}'));
    exit(1);
  }

  //Define logger and REPL.
  AtSignLogger.root_level = verbose ? 'info' : 'warning';
  REPL repl = REPL(atSign, rootUrl: rootUrl);

  //Try to authenticate using the inputted atsigns keys.
  //Keys are usually located in C:\Users\{user}\.atsign\keys
  //or home directory\.atsign\keys
  try {
    stdout.write(blue.wrap("Connecting...   "));
    var success = await repl.authenticate();
    atClient = repl.atClient;
    if (!await atClient.syncService.isInSync()) {
      atClient.syncService.sync();
    }

    if (success) {
      stdout.writeln(green.wrap("Connected."));
    } else {
      stdout.writeln(red.wrap("Failed to authenticate"));
    }

    atClient = repl.atClient;
    stdout.writeln(
        lightGreen.wrap("use /help or help to see available commands"));
  } on PathNotFoundException catch (e) {
    stdout.writeln(red.wrap(
        'Authentication failed: You do not have the keys to this atSign'));
    logger.info(
        "$e :Could not authenticate atsign, either you don't own the keys or you have a typo in the atsign");

    exit(2);
  }

  var namespaceMsg = (enforceNamespace
      ? ""
      : "Namespaces will default to at_repl when needed.");
  stdout.writeln(yellow.wrap(namespaceMsg));

  // 3. REPL!

  // Interactive mode state
  bool inInteractiveMode = false;
  bool waitingForAction = false;
  List<AtKey> interactiveAtKeys = [];
  AtKey? selectedKey;
  String interactiveRegex = "";
  
  // Notification interactive mode state
  bool inNotifyInteractiveMode = false;
  bool notifyWaitingForAction = false;
  List<dynamic> notifyInteractiveList = [];
  int? selectedNotifyIndex;
  
  // Monitor mode state
  bool inMonitorMode = false;
  StreamSubscription<AtNotification>? monitorSubscription;

  stdout.write(magenta.wrap("$atSign "));

  var lines = stdin.transform(utf8.decoder).transform(const LineSplitter());
  await for (String command in lines) {
    // receive a String from stdin
    try {
      if (command.isNotEmpty) {
        command = command.trim();
        
        // Handle monitor mode
        if (inMonitorMode) {
          if (command.toLowerCase() == 'q' || command.toLowerCase() == 'quit' || command.toLowerCase() == 'stop') {
            stdout.writeln(lightGreen.wrap("Stopping monitor mode..."));
            inMonitorMode = false;
            await monitorSubscription?.cancel();
            monitorSubscription = null;
            stdout.write(magenta.wrap("$atSign "));
            continue;
          } else {
            stdout.writeln(yellow.wrap("Monitor mode is active. Use 'q', 'quit', or 'stop' to exit monitor mode."));
            continue;
          }
        }
        
        // Handle notification inspect mode
        if (inNotifyInteractiveMode) {
          if (notifyWaitingForAction && selectedNotifyIndex != null) {
            String action = command.toLowerCase();
            notifyWaitingForAction = false;
            
            if (action == 'v' || action == 'view' || action == 'd' || action == 'delete') {
              bool shouldRefresh = await repl.handleNotifyAction(action, notifyInteractiveList, selectedNotifyIndex);
              
              if (shouldRefresh) {
                // Refresh the notification list
                var notifyResult = await repl.inspectNotify();
                if (notifyResult.shouldEnterInteractiveMode) {
                  notifyInteractiveList = notifyResult.notifications;
                } else {
                  inNotifyInteractiveMode = false;
                  stdout.write(magenta.wrap("$atSign "));
                  continue;
                }
              }
              
              selectedNotifyIndex = null;
              stdout.writeln(lightBlue.wrap("\nEnter notification index (1-${notifyInteractiveList.length}), 'l' to refresh list, or 'q' to quit:"));
              continue;
            } else {
              stdout.writeln(yellow.wrap("Invalid action. Use 'v' to view or 'd' to delete."));
              selectedNotifyIndex = null;
              stdout.writeln(lightBlue.wrap("\nEnter notification index (1-${notifyInteractiveList.length}), 'l' to refresh list, or 'q' to quit:"));
              continue;
            }
          }
          
          if (command.toLowerCase() == 'q' || command.toLowerCase() == 'quit') {
            stdout.writeln(lightGreen.wrap("Exiting notification inspect mode..."));
            inNotifyInteractiveMode = false;
            stdout.write(magenta.wrap("$atSign "));
            continue;
          }
          
          if (command.toLowerCase() == 'l' || command.toLowerCase() == 'list') {
            // Refresh the notification list
            var notifyResult = await repl.inspectNotify();
            if (notifyResult.shouldEnterInteractiveMode) {
              notifyInteractiveList = notifyResult.notifications;
            } else {
              inNotifyInteractiveMode = false;
              stdout.write(magenta.wrap("$atSign "));
            }
            continue;
          }
          
          int? index = int.tryParse(command);
          if (index != null && index >= 1 && index <= notifyInteractiveList.length) {
            selectedNotifyIndex = index;
            var notification = notifyInteractiveList[index - 1];
            String from = notification['from'] ?? 'N/A';
            String to = notification['to'] ?? 'N/A';
            stdout.writeln(lightCyan.wrap("Selected notification #$index from $from to $to"));
            stdout.writeln(lightBlue.wrap("Choose action: (v)iew or (d)elete"));
            notifyWaitingForAction = true;
            continue;
          } else {
            stdout.writeln(yellow.wrap("Invalid selection. Please enter a number between 1 and ${notifyInteractiveList.length}, 'l' to refresh list, or 'q' to quit."));
            stdout.writeln(lightBlue.wrap("\nEnter notification index (1-${notifyInteractiveList.length}), 'l' to refresh list, or 'q' to quit:"));
            continue;
          }
        }
        
        // Handle inspect mode
        if (inInteractiveMode) {
          if (waitingForAction && selectedKey != null) {
            String action = command.toLowerCase();
            waitingForAction = false;
            
            if (action == 'v' || action == 'view') {
              try {
                var atValue = await atClient.get(selectedKey);
                String rawValue = atValue.value ?? '';
                
                stdout.writeln(lightCyan.wrap("Raw Value: $rawValue"));
                
                // Try to parse as JSON and format it
                try {
                  var jsonObject = jsonDecode(rawValue);
                  JsonEncoder encoder = JsonEncoder.withIndent('  ');
                  String formattedJson = encoder.convert(jsonObject);
                  stdout.writeln(lightGreen.wrap("JSON Formatted:"));
                  stdout.writeln(lightGreen.wrap(formattedJson));
                } catch (e) {
                  // Not valid JSON, just show raw value
                }
              } catch (e) {
                stdout.writeln(red.wrap("Error getting value: ${e.toString()}"));
              }
            } else if (action == 'd' || action == 'delete') {
              try {
                var response = await atClient.delete(selectedKey);
                stdout.writeln(lightCyan.wrap("Deleted: $response"));
                
                var allAtKeys = await atClient.getAtKeys();
                interactiveAtKeys = await atClient.getAtKeys(regex: interactiveRegex);
                stdout.writeln(lightGreen.wrap("AtKey deleted successfully."));
                
                if (interactiveAtKeys.isEmpty) {
                  if (interactiveRegex.isNotEmpty) {
                    stdout.writeln(yellow.wrap("No more AtKeys found matching regex '$interactiveRegex'. Exiting inspect mode."));
                  } else {
                    stdout.writeln(yellow.wrap("No more AtKeys found. Exiting inspect mode."));
                  }
                  inInteractiveMode = false;
                  stdout.write(magenta.wrap("$atSign "));
                  continue;
                }
                
                if (interactiveRegex.isNotEmpty) {
                  stdout.writeln(lightGreen.wrap("Updated AtKeys list: ${interactiveAtKeys.length}/${allAtKeys.length} keys shown with regex '$interactiveRegex'"));
                } else {
                  stdout.writeln(lightGreen.wrap("Updated AtKeys list:"));
                }
                
                for (int i = 0; i < interactiveAtKeys.length; i++) {
                  stdout.writeln("${i + 1}. ${interactiveAtKeys[i].toString()}");
                }
              } catch (e) {
                stdout.writeln(red.wrap("Error deleting: ${e.toString()}"));
              }
            } else {
              stdout.writeln(yellow.wrap("Invalid action. Use 'v' for view or 'd' for delete."));
            }
            
            stdout.writeln(lightBlue.wrap("\nEnter the number of the AtKey you want to interact with (or 'q' to quit):"));
            continue;
          }
          
          if (command.toLowerCase() == 'q' || command.toLowerCase() == 'quit') {
            stdout.writeln(lightGreen.wrap("Exiting inspect mode..."));
            inInteractiveMode = false;
            stdout.write(magenta.wrap("$atSign "));
            continue;
          }
          
          int? index = int.tryParse(command);
          if (index != null && index >= 1 && index <= interactiveAtKeys.length) {
            selectedKey = interactiveAtKeys[index - 1];
            stdout.writeln(lightCyan.wrap("Selected: ${selectedKey.toString()}"));
            stdout.writeln(lightBlue.wrap("Choose action: (v)iew or (d)elete"));
            waitingForAction = true;
            continue;
          } else {
            stdout.writeln(yellow.wrap("Invalid selection. Please enter a number between 1 and ${interactiveAtKeys.length}, or 'q' to quit."));
            stdout.writeln(lightBlue.wrap("\nEnter the number of the AtKey you want to interact with (or 'q' to quit):"));
            continue;
          }
        }
        
        if (command == "help" ||
            command.startsWith("_") ||
            command.startsWith("/") ||
            command.startsWith("\\")) {
          if (command != "help") {
            command = command.substring(1);
          }
          var args = command.split(" ");
          String verb = args[0];
          switch (verb) {
            case "help":
              printHelpInstructions();
              break;
            case "scan":
              await repl.scan(args);
              break;
            case "get":
              try {
                var response = await repl.getKey(args);
                stdout.writeln(lightCyan.wrap(response));
              } catch (e) {
                stdout.writeln(red.wrap(e.toString()));
              }
              break;
            case "put":
              try {
                var response = await repl.put(args, enforceNamespace);
                stdout.writeln(lightCyan.wrap(response));
              } catch (e) {
                stdout.writeln(red.wrap(e.toString()));
              }
              break;
            case "delete":
              try {
                var response = await repl.delete(args);
                stdout.writeln(lightCyan.wrap(response));
              } catch (e) {
                stdout.writeln(red.wrap(e.toString()));
              }
              break;
            case "inspect":
              var inspectResult = await repl.inspect(args);
              if (inspectResult.shouldEnterInteractiveMode) {
                interactiveAtKeys = inspectResult.atKeys;
                interactiveRegex = inspectResult.regex;
                inInteractiveMode = true;
              }
              break;
            case "inspect_notify":
              var notifyResult = await repl.inspectNotify();
              if (notifyResult.shouldEnterInteractiveMode) {
                notifyInteractiveList = notifyResult.notifications;
                inNotifyInteractiveMode = true;
              }
              break;
            case "monitor":
              var subscription = await repl.monitor(args);
              if (subscription != null) {
                monitorSubscription = subscription;
                inMonitorMode = true;
              }
              break;
            case "q":
              exit(0);
            case "quit":
              exit(0);
          }
        } else {
          // run protocol verbs
          try {
            var response = await repl.executeCommand('$command\n');
            stdout.writeln(cyan.wrap("=> $response"));
          } on AtException catch (e) {
            stdout.writeln("atException: ${red.wrap(e.toString())}");
          } on IOException catch (e) {
            stdout.writeln(red.wrap(e.toString()));
          }
        }
      }
      
      if (!inInteractiveMode && !inNotifyInteractiveMode && !inMonitorMode) {
        stdout.write(magenta.wrap("$atSign "));
      }
    } on RangeError catch (e) {
      if (!command.contains(".")) {
        stdout.writeln(red.wrap(e.toString()));
      } else {
        stdout.writeln(red.wrap("You are missing the atsign"));
      }
      
      if (!inInteractiveMode && !inNotifyInteractiveMode && !inMonitorMode) {
        stdout.write(magenta.wrap("$atSign "));
      }
    }
  }
}

void printHelpInstructions() {
  stdout.writeln(lightRed.wrap("\n AtClient REPL"));
  stdout.writeln("Notes:");
  stdout.writeln(
      "    1) By default, REPL treats input as atProtocol commands. Use / for additional commands listed below");

  stdout.write(
      "    2) In the usage examples below, it is assumed that the atSign being used is ");
  stdout.writeln(green.wrap("@alice \n"));
  stdout.write(magenta.wrap(" help or /help"));
  stdout.writeln("- print this help message \n");

  stdout.write(magenta.wrap("/scan"));
  stdout.write(green.wrap(" [regex] "));
  stdout.writeln(
      "- scan for all records, or all records whose keyNames match the regex (e.g. /scan test@alice.*) \n");

  stdout.write(magenta.wrap("/put"));
  stdout.write(green.wrap(" <atKeyName> "));
  stdout.write(lightBlue.wrap(" <value> "));
  stdout.writeln(
      "- create or update a record with the given atKeyName and with the supplied value \n  For example: ");

  stdout.write(magenta.wrap("   /put"));
  stdout.write(green.wrap(" test@alice "));
  stdout.write(lightBlue.wrap(" secrets  "));
  stdout.writeln(
      "->  will create or update a 'self' record (a record private just to @alice)");

  stdout.write(magenta.wrap("   /put"));
  stdout.write(green.wrap(" @bob:test@alice "));
  stdout.write(lightBlue.wrap(" Hello, Bob!  "));
  stdout.writeln(
      "->  will create or update a record encrypted for, and then shared with, @bob \n");

  stdout.write(magenta.wrap("/get"));
  stdout.write(green.wrap(" <atKeyName> "));
  stdout.writeln(
      "- retrieve a value from the record with this atKeyName \n For example: ");

  stdout.write(magenta.wrap("   /get"));
  stdout.write(green.wrap(" test@alice "));
  stdout.writeln("- retrieve a value from test@alice. \n");

  stdout.write(magenta.wrap("/delete"));
  stdout.write(green.wrap(" <atKeyName> "));
  stdout.writeln(
      "- delete the record with this atKeyName (e.g. /delete test@alice) \n");

  stdout.write(magenta.wrap("/q or /quit"));
  stdout.writeln("- will quit the REPL \n");

  stdout.write(magenta.wrap("/inspect"));
  stdout.write(green.wrap(" [regex] "));
  stdout.writeln("- enter inspect mode to browse and manage AtKeys, optionally filtered by regex (default: excludes shared_key, publickey, and signing_privatekey) \n");

  stdout.write(magenta.wrap("/inspect_notify"));
  stdout.writeln("- enter notification inspect mode to browse and manage notifications (view/delete) \n");

  stdout.write(magenta.wrap("/monitor"));
  stdout.write(green.wrap(" [regex] "));
  stdout.writeln("- start monitoring notifications from the atServer with optional regex filtering (default: ignores statsNotification) \n");
}

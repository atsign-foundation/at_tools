import 'dart:async';

import 'package:at_test_proxy/src/message.dart';
import 'package:at_test_proxy/src/serial.dart';

const commands = [
  ForwardCommand(),
  ModifyCommand(),
  RespondCommand(),
  SkipCommand(),
];

FutureOr<void> parseAndExecuteCommand(Message message, String line) {
  var parts = line.split(" ");
  if (parts.isEmpty) {
    return null;
  }

  for (var cmd in commands) {
    if (parts[0] == cmd.command || parts[0] == cmd.abbr) {
      return cmd.run(message, parts.sublist(1).join(" "));
    }
  }
}

abstract class Command {
  final String help;
  final String command;
  final String? abbr;

  const Command({required this.help, required this.command, this.abbr});

  FutureOr<void> run(Message message, String? commandArgs);
}

/// Used by forward and modify
void _forwardMessage(Message message, {String? messageContents}) {
  if (message.clientSocket == null) {
    throw Exception("No client socket is set, cannot forward");
  }
  switch (message.status) {
    case MessageStatus.response:
      message.serverSocket.write(messageContents ?? message.value);
    case MessageStatus.request:
      message.clientSocket!.write(messageContents ?? message.value);
    case MessageStatus.none:
      throw Exception("Nothing to forward");
  }
}

class ForwardCommand extends Command {
  const ForwardCommand()
      : super(
          help: "Forward this command, as if the proxy weren't even here",
          command: "forward",
          abbr: "f",
        );

  @override
  void run(Message message, String? commandArgs) {
    _forwardMessage(message);
  }
}

class ModifyCommand extends Command {
  const ModifyCommand()
      : super(
          help: "modify the message before forwarding it",
          command: "modify",
          abbr: "m",
        );

  @override
  void run(Message message, String? commandArgs) {
    _forwardMessage(message, messageContents: commandArgs);
  }
}

class RespondCommand extends Command {
  const RespondCommand()
      : super(
          help: "Respond to the request without forwarding",
          command: "respond",
          abbr: "r",
        );

  @override
  void run(Message message, String? commandArgs) {
    if (message.status != MessageStatus.request) {
      throw Exception(
          "Not handling a request, respond is invalid for this operation");
    }
    if (commandArgs == null) {}
    message.serverSocket.write(commandArgs);
  }
}

class SkipCommand extends Command {
  const SkipCommand()
      : super(
          help: "Skip/ignore this message",
          command: "skip",
          abbr: "s",
        );

  @override
  void run(Message message, String? commandArgs) {
    // noop
  }
}

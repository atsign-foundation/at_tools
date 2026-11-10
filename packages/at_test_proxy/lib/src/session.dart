import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:at_test_proxy/src/command.dart';
import 'package:at_test_proxy/src/message.dart';
import 'package:at_test_proxy/src/serial.dart';

enum StreamType {
  client,
  server,
}

Future<void> handleSession(
    int sessionId, Socket clientSocket, Socket serverSocket) async {
  StreamController<(StreamType, Uint8List)> unifiedStream =
      StreamController<(StreamType, Uint8List)>();

  int closed = 0;
  clientSocket.listen(
    (element) => unifiedStream.add((StreamType.client, element)),
    onDone: () {
      closed += 1;
      if (closed == 2) {
        unifiedStream.close();
      }
    },
    cancelOnError: true,
  );
  serverSocket.listen(
    (element) => unifiedStream.add((StreamType.server, element)),
    onDone: () {
      closed += 1;
      if (closed == 2) {
        unifiedStream.close();
      }
    },
    cancelOnError: true,
  );

  await unifiedStream.stream.forEach((element) async {
    var (type, bytes) = element;
    var status = switch (type) {
      StreamType.client => MessageStatus.response,
      StreamType.server => MessageStatus.request,
    };
    var value = String.fromCharCodes(bytes);
    var message = Message(
      status: status,
      value: value,
      serverSocket: serverSocket,
      clientSocket: clientSocket,
    );
    var res = await Serial.blockForInput("$sessionId:$status:$value");
    if (res != null) {
      await parseAndExecuteCommand(message, res);
    }
  });
}

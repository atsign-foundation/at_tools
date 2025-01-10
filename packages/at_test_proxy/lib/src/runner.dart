import 'dart:io';

import 'dart:async';
import 'package:at_test_proxy/src/session.dart';
import 'package:at_test_proxy/src/serial.dart';
import 'package:at_test_proxy/src/args.dart';

Future<void> startTlsServer(Args args) async {
  var context = SecurityContext();
  context.useCertificateChain(args.tlsPublicKeyPath!);
  context.usePrivateKey(args.tlsPrivateKeyPath!);
  context.setTrustedCertificates(args.tlsCertificatePath!);

  var serverSocket = await SecureServerSocket.bind(
    args.serverInfo.$1,
    args.serverInfo.$2,
    context,
  );

  Serial.log(
      "Started TLS server at ${args.serverInfo.$1}:${args.serverInfo.$2}");

  int sessionCounter = 0;
  await serverSocket.forEach((socket) async {
    sessionCounter += 1;
    var clientSocket =
        await SecureSocket.connect(args.serverInfo.$1, args.serverInfo.$2);

    Serial.log(
        "Creating TLS session $sessionCounter to ${args.serverInfo.$1}:${args.serverInfo.$2}");

    unawaited(handleSession(sessionCounter, clientSocket, socket));
  });
}

Future<void> startTcpServer(Args args) async {
  var serverSocket = await ServerSocket.bind(
    args.serverInfo.$1,
    args.serverInfo.$2,
  );

  Serial.log(
      "Started TCP server at ${args.serverInfo.$1}:${args.serverInfo.$2}");

  int sessionCounter = 0;
  await serverSocket.forEach((socket) async {
    sessionCounter += 1;
    var clientSocket = await Socket.connect(
      args.serverInfo.$1,
      args.serverInfo.$2,
    );

    Serial.log(
        "Creating TCP session $sessionCounter to ${args.serverInfo.$1}:${args.serverInfo.$2}");

    unawaited(handleSession(sessionCounter, clientSocket, socket));
  });
}

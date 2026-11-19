import 'dart:io';

import 'package:args/args.dart';
import 'package:at_test_proxy/src/serial.dart';

typedef HostInfo = (String host, int port);

class Args {
  final HostInfo serverInfo;
  final HostInfo? clientInfo;
  final bool useTLS;

  final String? tlsPublicKeyPath;
  final String? tlsPrivateKeyPath;
  final String? tlsCertificatePath;

  Args({
    required this.serverInfo,
    this.clientInfo,
    this.useTLS = true,
    this.tlsPublicKeyPath,
    this.tlsPrivateKeyPath,
    this.tlsCertificatePath,
  });
}

ArgParser getParser({bool allowTrailingOptions = true, int? usageLineLength}) {
  ArgParser parser = ArgParser(
      allowTrailingOptions: allowTrailingOptions,
      usageLineLength: usageLineLength);

  parser.addOption(
    "server",
    abbr: "s",
    mandatory: false,
    defaultsTo: "localhost:6464",
    help:
        "The server side connection information of the proxy (address of this proxy)",
    valueHelp: "host:port",
  );

  parser.addOption(
    "client",
    abbr: "c",
    help:
        "The client side connection information of the proxy (address of the thing we are proxying)",
    valueHelp: "host:port",
  );

  parser.addFlag(
    "raw-tcp",
    abbr: "r",
    negatable: false,
    help: "Disables TLS and uses raw TCP to accept connections",
  );

  parser.addOption(
    "pub",
    mandatory: false,
    help: "TLS server public key path",
  );

  parser.addOption(
    "priv",
    mandatory: false,
    help: "TLS server private key path",
  );

  parser.addOption(
    "cert",
    mandatory: false,
    help: "TLS trusted certificate path",
  );

  parser.addFlag("help", abbr: "h", negatable: false, callback: (wasParsed) {
    if (wasParsed) {
      print(parser.usage);
      exit(0);
    }
  });

  return parser;
}

Args parseArgs(List<String> argv) {
  var parser = getParser();
  final ArgResults res;
  try {
    res = parser.parse(argv);
  } catch (e) {
    Serial.log("Failed to parse args: $e");
    rethrow;
  }

  final HostInfo serverInfo;
  final HostInfo? clientInfo;
  final bool useTLS;
  String? tlsPublicKeyPath;
  String? tlsPrivateKeyPath;
  String? tlsCertificatePath;

  try {
    var serverParts = (res['server']! as String).split(":");
    var serverHost = serverParts[0];
    var serverPort = int.parse(serverParts[1]);

    serverInfo = (serverHost, serverPort);
    var clientParts = res['client']?.split(":");
    if (clientParts != null) {
      var clientHost = clientParts[0];
      var clientPort = int.parse(clientParts[1]);
      clientInfo = (clientHost, clientPort);
    } else {
      clientInfo = null;
    }

    var rawTcp = res['raw-tcp'] ?? false;
    useTLS = !rawTcp;

    if (useTLS) {
      tlsPublicKeyPath = res['pub'] ?? (throw "--pub is mandatory in TLS mode");
      tlsPrivateKeyPath =
          res['priv'] ?? (throw "--priv is mandatory in TLS mode");
      tlsCertificatePath =
          res['cert'] ?? (throw "--cert is mandatory in TLS mode");
    }
  } catch (e) {
    Serial.log("$e");
    rethrow;
  }

  return Args(
    serverInfo: serverInfo,
    clientInfo: clientInfo,
    useTLS: useTLS,
    tlsPublicKeyPath: tlsPublicKeyPath,
    tlsPrivateKeyPath: tlsPrivateKeyPath,
    tlsCertificatePath: tlsCertificatePath,
  );
}

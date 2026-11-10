import 'dart:io';

enum MessageStatus {
  response, // from client to server
  request, // from server to client
  none,
}

class Message {
  final MessageStatus status;
  final String value; // Message from the socket
  final Socket serverSocket;
  final Socket? clientSocket;

  const Message({
    required this.status,
    required this.value,
    required this.serverSocket,
    required this.clientSocket,
  });
}

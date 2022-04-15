import 'package:at_commons/src/keystore/at_key.dart';

/// The class [AtException] and its subclasses represents various exceptions that can arise
/// while using the @ protocol.
class AtException implements Exception {
  // ignore: prefer_typing_uninitialized_variables
  /// Represents error message that details the cause of the exception
  var message;

  AtException(this.message);

  @override
  String toString() {
    return 'Exception: $message';
  }
}

/// The class [AtConnectException] and its subclasses represent any connection related issues while
/// trying to establish a socket connection to root or secondary server
class AtConnectException extends AtException {
  AtConnectException(message) : super(message);
}

/// Exception thrown when there is any issue related to socket operations e.g read/write
class AtIOException extends AtException {
  AtIOException(message) : super(message);
}

/// Exception thrown for critical issue during secondary or root server startup operation
@Deprecated('use at_server_exceptions.AtServerException')
class AtServerException extends AtException {
  AtServerException(message) : super(message);
}

/// Exception thrown when an @ protocol verb has an invalid syntax.
class InvalidSyntaxException extends AtException {
  InvalidSyntaxException(message) : super(message);
}

/// Exception thrown when an atsign name provided is invalid.
class InvalidAtSignException extends AtException {
  InvalidAtSignException(message) : super(message);
}

/// Thrown if the atsign is in blocklist.
@Deprecated('use at_server_exceptions.BlockedConnectionException')
class BlockedConnectionException extends AtException {
  BlockedConnectionException(message) : super(message);
}

/// Exception thrown when data size passed to the socket is greater than configured buffer size
class BufferOverFlowException extends AtException {
  BufferOverFlowException(message) : super(message);
}

/// Thrown when lookup fails after handshake
@Deprecated('use at_server_exceptions.LookupException')
class LookupException extends AtException {
  LookupException(message) : super(message);
}

/// Thrown for any unhandled server exception
@Deprecated('use at_server_exceptions.InternalServerException')
class InternalServerException extends AtException {
  InternalServerException(message) : super(message);
}

/// Thrown for any unhandled server error
@Deprecated('use at_server_exceptions.InternalServerError')
class InternalServerError extends AtException {
  InternalServerError(message) : super(message);
}

/// Exception thrown when a client tries to execute a verb or establish a connection but doesn't have the required permissions
class UnAuthorizedException extends AtConnectException {
  UnAuthorizedException(message) : super(message);
}

/// Exception thrown when the requested atsign's secondary url is not present in Root server
class SecondaryNotFoundException extends AtConnectException {
  SecondaryNotFoundException(message) : super(message);
}

/// Exception thrown when an atsign's secondary url cannot be reached or is unavailable
class SecondaryConnectException extends AtException {
  SecondaryConnectException(message) : super(message);
}

/// Exception thrown
class HandShakeException extends AtConnectException {
  HandShakeException(message) : super(message);
}

/// Thrown when current server's inbound connection limit is reached
@Deprecated('use at_server_exceptions.InboundConnectionLimitException')
class InboundConnectionLimitException extends AtConnectException {
  InboundConnectionLimitException(message) : super(message);
}

/// Thrown when current server's outbound connection limit is reached
@Deprecated('use at_server_exceptions.OutboundConnectionLimitException')
class OutboundConnectionLimitException extends AtConnectException {
  OutboundConnectionLimitException(message) : super(message);
}

/// Thrown when trying to perform a verb execution which requires authentication
class UnAuthenticatedException extends AtConnectException {
  UnAuthenticatedException(message) : super(message);
}

/// Thrown when trying to perform a read/write on a connection which is invalid
class ConnectionInvalidException extends AtConnectException {
  ConnectionInvalidException(message) : super(message);
}

/// Thrown when trying to perform a read/write on an outbound connection which is invalid
class OutBoundConnectionInvalidException extends AtConnectException {
  OutBoundConnectionInvalidException(message) : super(message);
}

/// Exception thrown when [AtKey.key] is not present in the keystore
class KeyNotFoundException extends AtException {
  KeyNotFoundException(message) : super(message);
}

/// Exception thrown when any parameter in a verb command is invalid
class IllegalArgumentException extends AtException {
  IllegalArgumentException(message) : super(message);
}

/// Throws when no response is received before the timeout duration
class AtTimeoutException extends AtException {
  AtTimeoutException(message) : super(message);
}

class RootServerConnectivityException extends AtConnectException {
  RootServerConnectivityException(message) : super(message);
}

class SecondaryServerConnectivityException extends AtConnectException {
  SecondaryServerConnectivityException(message) : super(message);
}

class InvalidRequestException extends AtException {
  InvalidRequestException(message) : super(message);
}

class InvalidResponseException extends AtException {
  InvalidResponseException(message) : super(message);
}

class AtCertificateValidationException extends AtException {
  AtCertificateValidationException(message) : super(message);
}

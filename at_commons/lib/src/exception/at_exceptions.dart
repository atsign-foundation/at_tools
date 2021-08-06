class AtException implements Exception {
  String message;

  AtException(this.message);
}

/// Parent exception for any connection specific exception
class AtConnectException extends AtException {
  AtConnectException(String message) : super(message);
}

/// Raised when there is any issue related to socket operations e.g read/write
class AtIOException extends AtException {
  AtIOException(String message) : super(message);
}

/// Raised for critical issue during secondary or root server startup operation
class AtServerException extends AtException {
  AtServerException(String message) : super(message);
}

/// Thrown for invalid syntax before executing a verb.
class InvalidSyntaxException extends AtException {
  InvalidSyntaxException(String message) : super(message);
}

/// Thrown if the atSign is invalid
class InvalidAtSignException extends AtException {
  InvalidAtSignException(String message) : super(message);
}

/// Thrown if the atsign is in blocklist.
class BlockedConnectionException extends AtException {
  BlockedConnectionException(String message) : super(message);
}

class BufferOverFlowException extends AtException {
  BufferOverFlowException(String message) : super(message);
}

/// Thrown when lookup fails after handshake
class LookupException extends AtException {
  LookupException(String message) : super(message);
}

/// Thrown for any unhandled server exception
class InternalServerException extends AtException {
  InternalServerException(String message) : super(message);
}

/// Thrown for any unhandled server error
class InternalServerError extends AtException {
  InternalServerError(String message) : super(message);
}

/// Thrown when trying to execute a command with authorization e.g Performing a lookup without
/// a proper handshake to another secondary
class UnAuthorizedException extends AtConnectException {
  UnAuthorizedException(String message) : super(message);
}

/// Thrown when a user's secondary server is not found
class SecondaryNotFoundException extends AtConnectException {
  SecondaryNotFoundException(String message) : super(message);
}

/// Thrown when a user's secondary url cannot be reached or unavailable
class SecondaryConnectException extends AtConnectException {
  SecondaryConnectException(String message) : super(message);
}

/// Thrown when a handshake to another secondary server fails
class HandShakeException extends AtConnectException {
  HandShakeException(String message) : super(message);
}

/// Thrown when current server's inbound connection limit is reached
class InboundConnectionLimitException extends AtConnectException {
  InboundConnectionLimitException(String message) : super(message);
}

/// Thrown when current server's outbound connection limit is reached
class OutboundConnectionLimitException extends AtConnectException {
  OutboundConnectionLimitException(String message) : super(message);
}

/// Thrown when trying to perform a verb execution which requires authentication
class UnAuthenticatedException extends AtConnectException {
  UnAuthenticatedException(String message) : super(message);
}

/// Thrown when trying to perform a read/write on a connection which is invalid
class ConnectionInvalidException extends AtConnectException {
  ConnectionInvalidException(String message) : super(message);
}

/// Thrown when trying to perform a read/write on an outbound connection which is invalid
class OutBoundConnectionInvalidException extends AtConnectException {
  OutBoundConnectionInvalidException(String message) : super(message);
}

/// Throws when users tries to perform an invalid operation.
class KeyNotFoundException extends AtException {
  KeyNotFoundException(String message) : super(message);
}

/// Throws when user inputs invalid arguments
class IllegalArgumentException extends AtException {
  IllegalArgumentException(String message) : super(message);
}

class AtClientException implements Exception {
  String? errorMessage;

  AtClientException(this.errorMessage);

  @override
  String toString() {
    return '$errorMessage';
  }
}

class AtKeyException extends AtClientException {
  AtKeyException(message) : super(message);
}

class AtValueException extends AtClientException {
  AtValueException(message) : super(message);
}

class AtEncryptionException extends AtClientException {
  AtEncryptionException(message) : super(message);
}

class AtPublicKeyChangeException extends AtEncryptionException {
  AtPublicKeyChangeException(message) : super(message);
}

class AtPublicKeyNotFoundException extends AtEncryptionException {
  AtPublicKeyNotFoundException(message) : super(message);
}

class AtDecryptionException extends AtClientException {
  AtDecryptionException(message) : super(message);
}

class InvalidRequestException extends AtClientException {
  InvalidRequestException(message) : super(message);
}

class InvalidResponseException extends AtClientException {
  InvalidResponseException(message) : super(message);
}

class InvalidAtSignException extends AtClientException {
  InvalidAtSignException(message) : super(message);
}

class AtConnectivityException extends AtClientException {
  AtConnectivityException(message) : super(message);
}

class RootServerConnectivityException extends AtConnectivityException {
  RootServerConnectivityException(message) : super(message);
}

class SecondaryServerConnectivityException extends AtConnectivityException {
  SecondaryServerConnectivityException(message) : super(message);
}

class AtCertificateValidationException extends AtConnectivityException {
  AtCertificateValidationException(message) : super(message);
}

class TimeoutException extends AtClientException {
  TimeoutException(message) : super(message);
}

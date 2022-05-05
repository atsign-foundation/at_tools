import 'package:at_commons/src/exception/at_exceptions.dart';

class AtClientException extends AtException {
  /// The default constructor to preserve the backward compatibility.
  AtClientException(errorCode, message) : super(message);

  /// The named constructor that takes only message
  AtClientException.message(message) : super(message);
}

class AtKeyException extends AtClientException {
  AtKeyException(message) : super.message(message);
}

class AtValueException extends AtClientException {
  AtValueException(message) : super.message(message);
}

class AtEncryptionException extends AtClientException {
  AtEncryptionException(message) : super.message(message);
}

class AtPublicKeyChangeException extends AtEncryptionException {
  AtPublicKeyChangeException(message) : super(message);
}

class AtPublicKeyNotFoundException extends AtEncryptionException {
  AtPublicKeyNotFoundException(message) : super(message);
}

class AtDecryptionException extends AtClientException {
  AtDecryptionException(message) : super.message(message);
}

import 'package:at_commons/src/exception/at_exceptions.dart';

class AtClientException extends AtException {
  // Adding error code to preserve backward compatibility.
  static String errorCode = 'NA';

  AtClientException(errorCode, message) : super(message);
}

class AtKeyException extends AtClientException {
  AtKeyException(message) : super(AtClientException.errorCode, message);
}

class AtValueException extends AtClientException {
  AtValueException(message) : super(AtClientException.errorCode, message);
}

class AtEncryptionException extends AtClientException {
  AtEncryptionException(message) : super(AtClientException.errorCode, message);
}

class AtPublicKeyChangeException extends AtEncryptionException {
  AtPublicKeyChangeException(message) : super(message);
}

class AtPublicKeyNotFoundException extends AtEncryptionException {
  AtPublicKeyNotFoundException(message) : super(message);
}

class AtDecryptionException extends AtClientException {
  AtDecryptionException(message) : super(AtClientException.errorCode, message);
}

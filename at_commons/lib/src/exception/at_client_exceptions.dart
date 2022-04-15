import 'package:at_commons/src/exception/at_exceptions.dart';

class AtClientException extends AtException {
  AtClientException(message) : super(message);
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

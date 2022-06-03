import 'package:at_commons/at_commons.dart';

/// AtExceptionManager is responsible for creating instances of the appropriate exception
/// classes for a given exception scenario.
class AtExceptionManager {
  static AtException createException(AtException atException) {
    // If the instance of atException is AtClientException. return as is.
    if (atException is AtClientException) {
      return atException;
    }
    // Else wrap the atException into AtClientException and return.
    return (AtClientException.message(atException.message))..fromException(atException);

  }
}

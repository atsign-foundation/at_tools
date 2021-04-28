import 'package:at_commons/at_commons.dart';

class AtMetadataUtil {
  static final AtMetadataUtil _singleton = AtMetadataUtil._internal();

  factory AtMetadataUtil() {
    return _singleton;
  }

  AtMetadataUtil._internal();

  static int validateTTL(String ttl) {
    var ttl_ms;
    if (ttl != null) {
      ttl_ms = int.parse(ttl);
      if (ttl_ms <= 0) {
        throw InvalidSyntaxException(
            'Valid value for TTL should be greater than or equal to 1');
      }
    }
    return ttl_ms;
  }

  static int validateTTB(String ttb) {
    var ttb_ms;
    if (ttb != null) {
      ttb_ms = int.parse(ttb);
      if (ttb_ms <= 0) {
        throw InvalidSyntaxException(
            'Valid value for TTB should be greater than or equal to 1');
      }
    }
    return ttb_ms;
  }

  static int validateTTR(int ttr_ms) {
    if (ttr_ms == null || ttr_ms == 0) {
      return null;
    }
    if (ttr_ms <= -2) {
      throw InvalidSyntaxException(
          'Valid values for TTR are -1 and greater than or equal to 1');
    }
    return ttr_ms;
  }

  /// Throws [InvalidSyntaxException] if ttr is 0 or null.
  static bool validateCascadeDelete(int ttr, bool isCascade) {
    // When ttr is 0 or null, key is not cached, hence setting isCascade to null.
    if (ttr == 0 || ttr == null) {
      return null;
    }
    isCascade ??= false;
    return isCascade;
  }

  static bool getBoolVerbParams(String arg1) {
    if (arg1 == null) {
      return null;
    }
    if (arg1.toLowerCase() == 'true') {
      return true;
    }
    return false;
  }
}

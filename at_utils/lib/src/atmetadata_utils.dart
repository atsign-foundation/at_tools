import 'package:at_commons/at_commons.dart';

// Utility class for AtMetaData related operations
class AtMetadataUtil {
  static final AtMetadataUtil _singleton = AtMetadataUtil._internal();

  factory AtMetadataUtil() {
    return _singleton;
  }

  AtMetadataUtil._internal();

  /// Method to validate TTL
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

  /// Method to validate TTB
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

  /// Method to validate TTR
  static int validateTTR(String ttr) {
    var ttr_ms;
    if (ttr != null) {
      ttr_ms = int.parse(ttr);
      if (ttr_ms == 0 || ttr_ms <= -2) {
        throw InvalidSyntaxException(
            'Valid values for TTR are -1 and greater than or equal to 1');
      }
    }
    return ttr_ms;
  }

  /// Throws [InvalidSyntaxException] if ttr is 0 or null.
  static bool validateCascadeDelete(int ttr, String cascadeValue) {
    bool isCascade;
    if (cascadeValue != null) {
      if (ttr == 0 || ttr == null) {
        throw InvalidSyntaxException('TTR cannot be null on cascade delete');
      }
      cascadeValue = cascadeValue.toLowerCase();
    }
    isCascade = cascadeValue == 'true' ? true : false;
    return isCascade;
  }

  /// Returns true of we pass 'true' string ese return false
  static bool getBoolVerbParams(String arg1) {
    if (arg1 != null) {
      if (arg1.toLowerCase() == 'true') {
        return true;
      }
    }
    return false;
  }
}

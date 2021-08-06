import 'package:at_commons/at_commons.dart';

/// Utility class for atSign Metadata
class AtMetadataUtil {
  static final AtMetadataUtil _singleton = AtMetadataUtil._internal();

  factory AtMetadataUtil() {
    return _singleton;
  }

  AtMetadataUtil._internal();

  /// Returns the ttlMs of the given [ttl] (Time To Live).
  /// To know more about the ttl, please refer [here](https://stackoverflow.com/q/68673036/11847122).
  ///
  ///
  /// If the ttlMs is less than 1, throw InvalidSyntaxException error.
  static int? validateTTL(String? ttl) {
    int? ttlMs;
    if (ttl != null) {
      /// Parse the ttl to int
      ttlMs = int.parse(ttl);
      if (ttlMs < 1) {
        throw InvalidSyntaxException(
            'Valid value for TTL should be greater than or equal to 1');
      }
    }
    return ttlMs;
  }

  /// Returns the ttbMs of the given [ttb].
  /// To know more about the ttb, please refer [here](https://stackoverflow.com/q/68673036/11847122).
  ///
  ///
  /// If the ttbMs is less than 1, throw InvalidSyntaxException error.
  static int? validateTTB(String? ttb) {
    int? ttbMs;
    if (ttb != null) {
      ttbMs = int.parse(ttb);
      if (ttbMs < 1) {
        throw InvalidSyntaxException(
            'Valid value for TTB should be greater than or equal to 1');
      }
    }
    return ttbMs;
  }

  /// Returns the ttrMs of the given [ttr].
  /// To know more about the ttr, please refer [here](https://stackoverflow.com/q/68673036/11847122).
  ///
  ///
  /// If the ttrMs is less than -1 or 0, throw InvalidSyntaxException error.
  static int? validateTTR(int? ttrMs) {
    if (ttrMs == 0 || ttrMs! < -1) {
      throw InvalidSyntaxException(
          'Valid values for TTR are -1 and greater than or equal to 1');
    }
    return ttrMs;
  }

  /// Throws [InvalidSyntaxException] if ttr is 0 or null.
  static bool? validateCascadeDelete(int? ttr, bool? isCascade) {
    // When ttr is 0 or null, key is not cached, hence setting isCascade to null.
    if (ttr == 0 || ttr == null) {
      return null;
    }
    isCascade ??= false;
    return isCascade;
  }

  /// Returns a static boolean value.
  static bool getBoolVerbParams(String? arg1) {
    if (arg1 != null && arg1.toLowerCase() == 'true') {
      return true;
    }
    return false;
  }
}

import 'package:at_commons/src/keystore/key_type.dart';

/// Implement a validation on a key
abstract class Validation {
  ValidationResult doValidate();
}

/// Validates String representation of a [AtKey]
/// For example String representation of a public key [PublicKey] will be public:phone.wavi@bob
abstract class AtKeyValidator {
  ValidationResult validate(String key, ValidationContext context);
}

/// Represents context of a validation
/// See [AtKeyValidator]
class ValidationContext {
  late String atSign;
  KeyType? type;

  ValidationContext(this.atSign);
}

/// Represents outcome of a key validation
/// See [AtKeyValidator] and [AtConcreteKeyValidator]
class ValidationResult {
  late bool isValid = false;
  late String failureReason = '';

  ValidationResult(this.failureReason);

  static ValidationResult noFailure() {
    return ValidationResult('')..isValid = true;
  }
}

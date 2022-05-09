import 'package:at_commons/at_commons.dart';

/// Utility class that returns instance of exception for the given error code.
class AtExceptionUtils {
  /// Returns the instance of exception for the given error code.
  /// Defaults to return an instance of [AtException]
  static AtException get(String errorCode) {
    switch (errorCode) {
      case 'AT0001':
        return AtServerException('');
      case 'AT0003':
        return InvalidSyntaxException('');
      case 'AT0005':
        return BufferOverFlowException('');
      case 'AT0006':
        return OutboundConnectionLimitException('');
      case 'AT0007':
        return SecondaryNotFoundException('');
      case 'AT0008':
        return HandShakeException('');
      case 'AT0009':
        return UnAuthorizedException('');
      case 'AT0010':
        return InternalServerError('');
      case 'AT0011':
        return InternalServerException('');
      case 'AT0012':
        return InboundConnectionLimitException('');
      case 'AT0013':
        return BlockedConnectionException('');
      case 'AT0015':
        return KeyNotFoundException('');
      case 'AT0021':
        return SecondaryConnectException('');
      case 'AT0022':
        return IllegalArgumentException('');
      case 'AT0023':
        return AtTimeoutException('');
      case 'AT0401':
        return UnAuthenticatedException('');
      default:
        return AtException('');
    }
  }
}
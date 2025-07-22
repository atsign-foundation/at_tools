


import 'package:at_client/at_client.dart';

class InspectKeysResult {
  final List<AtKey> atKeys;
  final String regex;
  final bool shouldEnterInteractiveMode;

  InspectKeysResult(this.atKeys, this.regex, this.shouldEnterInteractiveMode);
}
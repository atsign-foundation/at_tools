import 'package:at_commons/at_commons.dart';
import 'package:at_commons/src/verb/verb_builder.dart';
import 'package:at_commons/src/verb/verb_util.dart';

/// Lookup verb builder generates a command to lookup [atKey] on either the client user's secondary server(without authentication)
/// or secondary server of [sharedBy] (with authentication).
/// Assume @bob is the client atSign. @alice is atSign on another secondary server.
/// e.g if you want to lookup @bob:phone@alice on alice's secondary,
/// user this builder to lookup value of phone@alice from bob's secondary. Auth has to be true.
/// ```
/// var builder = LookupVerbBuilder()..key=’phone’..atSign=’alice’..auth=true;
/// ```
///
/// e.g if you want to lookup public key on bob's secondary without auth from bob's client.
/// ```
/// var builder = LookupVerbBuilder()..key=’phone’..atSign=’bob’;
/// ```
class LookupVerbBuilder implements VerbBuilder {
  late AtKey atKey;

  /// Flag to specify whether to run this builder with or without auth.
  bool auth = false;

  String? operation;

  @override
  String buildCommand() {
    var command = 'lookup:';
    if (operation != null) {
      command += '$operation:';
    }
    if (atKey.namespace != null && atKey.namespace!.isNotEmpty &&
        (atKey.metadata != null && atKey.metadata!.namespaceAware)) {
      atKey.key += '.${atKey.namespace}';
    }
    command += '${atKey.key}${VerbUtil.formatAtSign(atKey.sharedBy)}\n';
    return command;
  }

  @override
  bool checkParams() {
    return atKey.sharedBy != null;
  }
}

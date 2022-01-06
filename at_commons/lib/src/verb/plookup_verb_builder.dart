import 'package:at_commons/at_commons.dart';
import 'package:at_commons/src/verb/verb_builder.dart';
import 'package:at_commons/src/verb/verb_util.dart';

/// Plookup builder generates a command to lookup public value of [atKey] on secondary server of another atSign [sharedBy].
/// e.g If @alice has a public key e.g. public:phone@alice then use this builder to
/// lookup value of phone@alice from bob's secondary
/// ```
/// var builder = PlookupVerbBuilder()..key=’phone’..atSign=’alice’;
/// ```
class PLookupVerbBuilder implements VerbBuilder {
  late AtKey atkey;

  String? operation;

  @override
  String buildCommand() {
    var command = 'plookup:';
    if (operation != null) {
      command += '$operation:';
    }
    command += '${atkey.key}${VerbUtil.formatAtSign(atkey.sharedBy)}\n';
    return command;
  }

  @override
  bool checkParams() {
    return atkey.sharedBy != null;
  }
}

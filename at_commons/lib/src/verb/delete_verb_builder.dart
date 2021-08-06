import 'dart:collection';

import 'package:at_commons/at_commons.dart';
import 'package:at_commons/src/verb/verb_builder.dart';
import 'package:at_commons/src/verb/verb_util.dart';

/// Delete verb builder generates a command to delete a [atKey] from the secondary server.
/// ```
/// // @bob deleting a public phone key
///    var deleteBuilder = DeleteVerbBuilder()..key = 'public:phone@bob';
/// // @bob deleting the key “phone” shared with @alice
///    var deleteBuilder = DeleteVerbBuilder()..key = '@alice:phone@bob';
/// ```
class DeleteVerbBuilder implements VerbBuilder {
  /// The key to delete
  String? atKey;

  /// atSign of the secondary server on which llookup has to be executed.
  String? sharedBy;

  /// atSign of the secondary server for whom [atKey] is shared
  String? sharedWith;

  bool isPublic = false;

  bool isCached = false;

  @override
  String buildCommand() {
    String command = 'delete:';

    if (isCached) {
      command += 'cached:';
    }

    if (isPublic) {
      command += 'public:';
    }

    if (sharedWith != null && sharedWith!.isNotEmpty) {
      command += '${VerbUtil.formatAtSign(sharedWith)}:';
    }
    if (sharedBy != null && sharedBy!.isNotEmpty) {
      command += '$atKey${VerbUtil.formatAtSign(sharedBy)}';
    } else {
      command += atKey!;
    }
    command += '\n';
    return command;
  }

  /// Returns a builder instance from a delete command
  static DeleteVerbBuilder getBuilder(String command) {
    DeleteVerbBuilder builder = DeleteVerbBuilder();
    HashMap<String, String?> verbParams = VerbUtil.getVerbParam(VerbSyntax.delete, command)!;
    builder.atKey = verbParams[AT_KEY];
    return builder;
  }

  @override
  bool checkParams() {
    return atKey != null;
  }
}

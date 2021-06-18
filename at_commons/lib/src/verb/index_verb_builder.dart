import 'package:at_commons/src/verb/verb_builder.dart';

/// Index verb builder generates a command to insert data into index server.
/// If a [data] is set, it will be inserted into index server.
/// ```
///
///  // Insert json data ({"name" : "@alice"}) into index server
///  var builder = IndexVerbBuilder()..data='{"name" : "@alice"}';
///
///  ```
class IndexVerbBuilder implements VerbBuilder {
  /// Data to insert into index server
  String data;

  ///Builds index command
  @override
  String buildCommand() {
    var indexCommand = 'index';
    if (data != null) {
      indexCommand += ':${data}';
    }
    indexCommand += '\n';
    return indexCommand;
  }

  @override
  bool checkParams() {
    return true;
  }
}

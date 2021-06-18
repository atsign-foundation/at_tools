import 'package:at_commons/src/verb/verb_builder.dart';

/// Search verb builder generates a command to search data in index server.
/// If a [keys] is set, it will be searched in index server.
/// ```
///
///  // Search keys (alice usa) into index server
///  // keys will be separated by comma or space
///  var builder = SearchVerbBuilder()..keys='alice usa';
///  var builder = SearchVerbBuilder()..keys='alice,usa';
///
///  ```
class SearchVerbBuilder implements VerbBuilder {
  /// Key to search in index server
  String keys;

  ///Builds search command
  @override
  String buildCommand() {
    var searchCommand = 'search';
    if (keys != null) {
      searchCommand += ':${keys}';
    }
    searchCommand += '\n';
    return searchCommand;
  }

  @override
  bool checkParams() {
    return true;
  }
}

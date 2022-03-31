import 'package:at_commons/at_builders.dart';

class NotifyDeleteVerbBuilder implements VerbBuilder {
  late String id;

  @override
  String buildCommand() {
    return 'notify:delete:$id\n';
  }

  @override
  bool checkParams() {
    // Returns false if id is not set
    return id.isNotEmpty;
  }
}

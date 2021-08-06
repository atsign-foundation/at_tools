import 'package:at_commons/src/verb/verb_builder.dart';

class NotifyStatusVerbBuilder implements VerbBuilder {
  /// Notification Id to query the status of notification
  String? notificationId;

  @override
  String buildCommand() {
    String command = 'notify:status:';
    if (notificationId != null) {
      command += '$notificationId\n';
    }
    return command;
  }

  @override
  bool checkParams() {
    bool isValid = true;
    if (notificationId == null) {
      isValid = false;
    }
    return isValid;
  }
}

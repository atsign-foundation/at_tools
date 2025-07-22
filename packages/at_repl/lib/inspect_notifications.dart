

class InspectNotificationsResult {
  final List<dynamic> notifications; // list of notification objects
  final bool shouldEnterInteractiveMode;

  InspectNotificationsResult(this.notifications, this.shouldEnterInteractiveMode);
}

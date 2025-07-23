/// Default regex patterns used throughout the at_repl application

/// Default regex for inspect command that excludes system keys
/// Excludes: shared_key, signing_privatekey, signing_publickey, publickey
const String defaultInspectRegex = '^(?!.*(shared_key|signing_privatekey|signing_publickey|publickey)).*';

/// Default regex for monitor command that excludes statsNotification
/// Excludes: statsNotification
const String defaultMonitorRegex = '^(?!.*statsNotification).*';
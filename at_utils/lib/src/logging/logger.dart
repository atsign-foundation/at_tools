import 'package:at_utils/src/logging/handlers.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:logging/logging.dart' as logging;

/// Class for AtSignLogger Implementation
class AtSignLogger {
  /// Late logger object
  late logging.Logger logger;

  /// level for AtSignLogger is `info`
  static String _rootLevel = 'info';
  bool hierarchicalLoggingEnabled = false;
  String? _level;

  AtSignLogger(String name) {
    logger = logging.Logger.detached(name);
    logger.onRecord.listen(ConsoleLoggingHandler());
    level = _rootLevel;
  }

  String? get level {
    return LogLevel.level.keys
        .firstWhereOrNull((k) => LogLevel.level[k].toString() == _level);
  }

  set level(String? value) {
    if (!hierarchicalLoggingEnabled) {
      hierarchicalLoggingEnabled = true;
      logging.hierarchicalLoggingEnabled = hierarchicalLoggingEnabled;
    }
    _level = value;
    logger.level = LogLevel.level[_level!];
  }

  bool isLoggable(String value) => (LogLevel.level[value]! >= logger.level);

  static set rootLevel(String rootLevel) {
    _rootLevel = rootLevel.toLowerCase();
    logging.Logger.root.level = LogLevel.level[_rootLevel] ??

        /// defaults to Level.INFO
        logging.Level.INFO;
  }

  static String get rootLevel {
    return _rootLevel;
  }

//log methods
  void shout(message, [Object? error, StackTrace? stackTrace]) =>
      logger.shout(message, error, stackTrace);

  void severe(message, [Object? error, StackTrace? stackTrace]) =>
      logger.severe(message, error, stackTrace);

  void warning(message, [Object? error, StackTrace? stackTrace]) =>
      logger.warning(message, error, stackTrace);

  void info(message, [Object? error, StackTrace? stackTrace]) =>
      logger.info(message, error, stackTrace);

  void finer(message, [Object? error, StackTrace? stackTrace]) =>
      logger.finer(message, error, stackTrace);

  void finest(message, [Object? error, StackTrace? stackTrace]) =>
      logger.finest(message, error, stackTrace);
}

class LogLevel {
  static final Map<String, logging.Level> level = {
    'info': logging.Level.INFO,
    'shout': logging.Level.SHOUT,
    'severe': logging.Level.SEVERE,
    'warning': logging.Level.WARNING,
    'finer': logging.Level.FINER,
    'finest': logging.Level.FINEST,
    'all': logging.Level.ALL
  };
}

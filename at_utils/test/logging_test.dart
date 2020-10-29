import 'dart:io';
import 'package:at_utils/at_logger.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  group('A group of fixAtSign tests', () {
    test('Test file logging', () => test_console_logging());
  });
}

void delete_file(filename) {
  var file = File(filename);
  if (file.existsSync()) {
    file.deleteSync();
  }
}

void test_console_logging() {
  var records = <LogRecord>[];
  var test_logger = AtSignLogger('test_console_logging');
  test_logger.logger.onRecord.listen(records.add);
  test_logger.info('hello');
  expect(records[0].message, 'hello');
}

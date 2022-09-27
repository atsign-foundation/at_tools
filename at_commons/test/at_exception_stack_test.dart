import 'package:at_commons/at_commons.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests for exception stack', () {
    test('chained exception list size greater than zero - check trace message',
        () {
      final atChainedException = AtChainedException(
          Intent.syncData, ExceptionScenario.invalidKeyFormed, 'sync issue');
      final exceptionStack = AtExceptionStack();
      exceptionStack.add(atChainedException);
      expect(exceptionStack.getTraceMessage(), isNotEmpty);
      expect(exceptionStack.getTraceMessage(),
          startsWith('Failed to syncData caused by'));
    });

    test('chained exception list size is zero', () {
      final exceptionStack = AtExceptionStack();
      expect(exceptionStack.getTraceMessage(), isEmpty);
    });

    test('check intent message', () {
      final atChainedException = AtChainedException(
          Intent.syncData, ExceptionScenario.invalidKeyFormed, 'sync issue');
      final exceptionStack = AtExceptionStack();
      exceptionStack.add(atChainedException);
      expect(exceptionStack.getIntentMessage(Intent.syncData), isNotEmpty);
      expect(exceptionStack.getIntentMessage(Intent.syncData),
          equals('Failed to syncData'));
    });
  });
}

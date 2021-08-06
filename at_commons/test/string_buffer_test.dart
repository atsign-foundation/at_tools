import 'package:at_commons/src/buffer/at_buffer.dart';
import 'package:at_commons/src/buffer/at_buffer_impl.dart' as sb;
import 'package:test/test.dart';

void main() {
  group('String buffer constructor tests', () {
    test('default terminating char', () => test_default_terminating_char());
    test('default capacity', () => test_default_capacity());
    test('override terminating char', () => test_override_terminating_char());
    test('override override capacity', () => test_override_capacity());
    test('override terminating char and capacity',
        () => test_override_terminating_char_and_capacity());
  });

  group('String buffer terminating char test', () {
    test('message contains terminating char',
        () => test_message_contains_default_terminating_char());
    test('message does not contain terminating char',
        () => test_message_not_contains_default_terminating_char());
    test('message contains overridden terminating char',
        () => test_message_contains_overridden_terminating_char());
    test('message does not contain overridden terminating char',
        () => test_message_contains_overridden_terminating_char());
  });

  group('String buffer capacity tests', () {
    test('buffer not full default capacity',
        () => test_buffer_not_full_default_capacity());
    test('buffer full overridden capacity',
        () => test_buffer_full_overrriden_capacity());
    test('buffer not full overridden capacity',
        () => test_buffer_not_full_overrriden_capacity());
  });

  group('String buffer append tests', () {
    test('buffer append once', () => test_buffer_append_once());
    test('buffer append multiple', () => test_buffer_append_multiple());
    test('can append default capacity',
        () => test_can_append_default_capacity());
    test('can append overridden capacity',
        () => test_can_append_overriden_capacity());
    test('cannot append overridden capacity',
        () => test_cannot_append_overriden_capacity());
    test('buffer overflow exception', () => test_buffer_overflow_exception());
  });
}

void test_default_terminating_char() {
  sb.StringBuffer buffer = sb.StringBuffer();
  expect(buffer.terminatingChar, '\n');
}

void test_default_capacity() {
  sb.StringBuffer buffer = sb.StringBuffer();
  expect(buffer.capacity, 4096);
}

void test_override_terminating_char() {
  sb.StringBuffer buffer = sb.StringBuffer(terminatingChar: 'q');
  expect(buffer.terminatingChar, 'q');
}

void test_override_capacity() {
  sb.StringBuffer buffer = sb.StringBuffer(capacity: 1000);
  expect(buffer.capacity, 1000);
}

void test_override_terminating_char_and_capacity() {
  sb.StringBuffer buffer = sb.StringBuffer(terminatingChar: 's', capacity: 100);
  expect(buffer.capacity, 100);
  expect(buffer.terminatingChar, 's');
}

void test_message_contains_default_terminating_char() {
  String data = 'hello\n';
  sb.StringBuffer buffer = sb.StringBuffer();
  buffer.append(data);
  expect(buffer.isEnd(), true);
}

void test_message_not_contains_default_terminating_char() {
  String data = 'hello';
  sb.StringBuffer buffer = sb.StringBuffer();
  buffer.append(data);
  expect(buffer.isEnd(), false);
}

void test_message_contains_overridden_terminating_char() {
  String data = 'hello%';
  sb.StringBuffer buffer = sb.StringBuffer(terminatingChar: '%');
  buffer.append(data);
  expect(buffer.isEnd(), true);
}

void test_message_not_contains_overridden_terminating_char() {
  String data = 'hello';
  sb.StringBuffer buffer = sb.StringBuffer(terminatingChar: '%');
  buffer.append(data);
  expect(buffer.isEnd(), false);
}

void test_buffer_not_full_default_capacity() {
  String data = 'hi';
  sb.StringBuffer buffer = sb.StringBuffer();
  buffer.append(data);
  expect(buffer.isFull(), false);
}

void test_buffer_full_overrriden_capacity() {
  String data = '1234567890';
  sb.StringBuffer buffer = sb.StringBuffer(capacity: 10);
  buffer.append(data);
  expect(buffer.isFull(), true);
}

void test_buffer_not_full_overrriden_capacity() {
  String data = '1234';
  sb.StringBuffer buffer = sb.StringBuffer(capacity: 10);
  buffer.append(data);
  expect(buffer.isFull(), false);
}

void test_buffer_append_once() {
  String data = 'Hello';
  sb.StringBuffer buffer = sb.StringBuffer();
  buffer.append(data);
  expect(buffer.getData(), 'Hello');
}

void test_buffer_append_multiple() {
  String data = 'Veni';
  sb.StringBuffer buffer = sb.StringBuffer();
  buffer.append(data);
  buffer.append('Vidi');
  buffer.append('Vici');
  expect(buffer.getData(), 'VeniVidiVici');
}

void test_can_append_default_capacity() {
  String data = 'Hello';
  sb.StringBuffer buffer = sb.StringBuffer();
  buffer.append(data);
  bool canAppend = buffer.canAppend('Hi');
  expect(canAppend, true);
}

void test_can_append_overriden_capacity() {
  String data = 'Hello';
  sb.StringBuffer buffer = sb.StringBuffer(capacity: 10);
  buffer.append(data);
  bool canAppend = buffer.canAppend('Hi');
  expect(canAppend, true);
}

void test_cannot_append_overriden_capacity() {
  String data = 'Hello';
  sb.StringBuffer buffer = sb.StringBuffer(capacity: 10);
  buffer.append(data);
  bool canAppend = buffer.canAppend('HelloThere');
  expect(canAppend, false);
}

void test_buffer_overflow_exception() {
  String data = 'Hello';
  sb.StringBuffer buffer = sb.StringBuffer(capacity: 10);
  buffer.append(data);
  try {
    buffer.append('HelloThere');
  } catch (e) {
    print(e);
  }
  expect(
      () => buffer.append('HelloThere'),
      throwsA(predicate((dynamic e) =>
          e is AtBufferOverFlowException &&
          e.message == 'String Buffer Overflow')));
}

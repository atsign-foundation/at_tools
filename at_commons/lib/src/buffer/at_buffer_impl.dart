import 'dart:convert';
import 'dart:typed_data';

import 'package:at_commons/src/buffer/at_buffer.dart';

class StringBuffer extends AtBuffer<String> {
  StringBuffer({var terminatingChar = '\n', int capacity = 4096}) {
    this.terminatingChar = terminatingChar;
    this.capacity = capacity;
    message = '';
  }

  @override
  void append(var data) {
    if (!canAppend(data)) {
      throw AtBufferOverFlowException('String Buffer Overflow');
    } else {
      message = message + data;
    }
  }

  bool canAppend(data) => length() + data.length <= capacity;

  @override
  bool isEnd() => message.endsWith(terminatingChar);

  @override
  bool isFull() => message?.length >= capacity;

  @override
  void clear() => message = '';

  @override
  int length() => message.length;
}

class ByteBuffer extends AtBuffer<List<int>> {
  ByteBuffer({var terminatingChar = '\n', int capacity = 4096}) {
    this.terminatingChar = utf8.encode(terminatingChar)[0];
    this.capacity = capacity;
    message = Uint8List.fromList(<int>[]);
  }

  @override
  void append(var data) {
    if (isOverFlow(data)) {
      throw AtBufferOverFlowException('Byte Buffer Overflow');
    } else {
      message = message + data;
    }
  }

  bool isOverFlow(data) => length() + data.length > capacity;

  @override
  bool isEnd() => message.last == terminatingChar;

  @override
  bool isFull() => message.length >= capacity;

  @override
  void clear() => message.clear();

  @override
  int length() => message.length;
}

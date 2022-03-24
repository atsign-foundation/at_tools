import 'package:at_commons/at_builders.dart';
import 'package:test/test.dart';

void main() {
  group('A group of notify verb builder tests to check notify command', () {
    test('notify public key', () {
      var notifyVerbBuilder = NotifyVerbBuilder()
        ..id = '123'
        ..value = 'alice@gmail.com'
        ..isPublic = true
        ..atKey = 'email'
        ..sharedBy = 'alice';
      expect(notifyVerbBuilder.buildCommand(),
          'notify:id:123:notifier:SYSTEM:public:email@alice:alice@gmail.com\n');
    });

    test('notify public key with ttl', () {
      var notifyVerbBuilder = NotifyVerbBuilder()
        ..id = '123'
        ..value = 'alice@gmail.com'
        ..isPublic = true
        ..atKey = 'email'
        ..sharedBy = 'alice'
        ..ttl = 1000;
      expect(notifyVerbBuilder.buildCommand(),
          'notify:id:123:notifier:SYSTEM:ttl:1000:public:email@alice:alice@gmail.com\n');
    });

    test('notify shared key command', () {
      var notifyVerbBuilder = NotifyVerbBuilder()
        ..id = '123'
        ..value = 'alice@atsign.com'
        ..atKey = 'email'
        ..sharedBy = 'alice'
        ..sharedWith = 'bob'
        ..pubKeyChecksum = '123'
        ..sharedKeyEncrypted = 'abc';
      expect(notifyVerbBuilder.buildCommand(),
          'notify:id:123:notifier:SYSTEM:sharedKeyEnc:abc:pubKeyCS:123:@bob:email@alice:alice@atsign.com\n');
    });
  });
}

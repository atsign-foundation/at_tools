import 'package:at_commons/at_builders.dart';
import 'package:at_commons/at_commons.dart';
import 'package:test/test.dart';

import 'syntax_test.dart';

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

  group('A group of tests to verify notification id generation', () {
    test('Test to verify default notification id is generated', () {
      var verbHandler = NotifyVerbBuilder()
        ..atKey = 'phone'
        ..sharedWith = '@alice'
        ..sharedBy = '@bob';

      var notifyCommand = verbHandler.buildCommand();
      var verbParams = getVerbParams(VerbSyntax.notify, notifyCommand.trim());
      expect(verbParams[ID] != null, true);
    });

    test('Test to verify custom set notification id to verb builder', () {
      var verbHandler = NotifyVerbBuilder()
        ..id = 'abc-123'
        ..atKey = 'phone'
        ..sharedWith = '@alice'
        ..sharedBy = '@bob';

      var notifyCommand = verbHandler.buildCommand();
      var verbParams = getVerbParams(VerbSyntax.notify, notifyCommand.trim());
      expect(verbParams[ID], 'abc-123');
    });
  });
}

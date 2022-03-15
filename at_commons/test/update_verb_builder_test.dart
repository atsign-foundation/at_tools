import 'package:at_commons/at_builders.dart';
import 'package:test/test.dart';

void main() {
  group('A group of update verb builder tests to check update command', () {
    test('verify public at key command', () {
      var updateBuilder = UpdateVerbBuilder()
        ..value = 'alice@gmail.com'
        ..isPublic = true
        ..atKey = 'email'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommand(),
          'update:public:email@alice alice@gmail.com\n');
    });

    test('verify private at key command', () {
      var updateBuilder = UpdateVerbBuilder()
        ..value = 'alice@atsign.com'
        ..atKey = 'email'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommand(),
          'update:email@alice alice@atsign.com\n');
    });

    test('verify shared key command', () {
      var updateBuilder = UpdateVerbBuilder()
        ..value = 'alice@atsign.com'
        ..atKey = 'email'
        ..sharedBy = 'alice'
        ..sharedWith = 'bob'
        ..pubKeyChecksum = '123'
        ..sharedKeyEncrypted = 'abc';
      expect(updateBuilder.buildCommand(),
          'update:sharedKeyEnc:abc:pubKeyCS:123:@bob:email@alice alice@atsign.com\n');
    });
  });

  group('A group of update verb builder tests to check update metadata command',
      () {
    test('verify isBinary metadata', () {
      var updateBuilder = UpdateVerbBuilder()
        ..isBinary = true
        ..atKey = 'phone'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommandForMeta(),
          'update:meta:phone@alice:isBinary:true\n');
    });

    test('verify ttl metadata', () {
      var updateBuilder = UpdateVerbBuilder()
        ..ttl = 60000
        ..atKey = 'phone'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommandForMeta(),
          'update:meta:phone@alice:ttl:60000\n');
    });

    test('verify ttr metadata', () {
      var updateBuilder = UpdateVerbBuilder()
        ..ttr = 50000
        ..atKey = 'phone'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommandForMeta(),
          'update:meta:phone@alice:ttr:50000\n');
    });

    test('verify ttb metadata', () {
      var updateBuilder = UpdateVerbBuilder()
        ..ttb = 80000
        ..atKey = 'phone'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommandForMeta(),
          'update:meta:phone@alice:ttb:80000\n');
    });
  });
}

import 'package:at_commons/at_commons.dart';
import 'package:at_commons/src/keystore/key_type.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests to verify key types', () {
    // test('Test to verify a public key type', () {
    //   var keyType = AtKey.getKeyType('public:phone@bob');
    //   expect(keyType, equals(KeyType.publicKey));
    //
    // });
    //
    // test('Test to verify a cached public key type', () {
    //   var keyType = AtKey.getKeyType('cached:public:phone@bob');
    //   expect(keyType, equals(KeyType.cachedPublicKey));
    //
    // });
    //
    // test('Test to verify a shared key type', () {
    //   var keyType = AtKey.getKeyType('@alice:phone@bob');
    //   expect(keyType, equals(KeyType.sharedKey));
    // });
    //
    // test('Test to verify a cached shared key type', () {
    //   var keyType = AtKey.getKeyType('cached:@alice:phone@bob');
    //   expect(keyType, equals(KeyType.cachedSharedKey));
    // });
    //
    // test('Test to verify self key type without sharedWith atsign', () {
    //   var keyType = AtKey.getKeyType('phone@bob');
    //   expect(keyType, equals(KeyType.selfKey));
    // });
    // test('Test to verify self key type with atsign', () {
    //   var keyType = AtKey.getKeyType('@bob:phone@bob');
    //   expect(keyType, equals(KeyType.selfKey));
    // });

    test('Test to verify a public key type with namespace', () {
      var keyType = AtKey.getKeyType('public:phone.wavi@bob');
      expect(keyType, equals(KeyType.publicKey));
    });

    test('Test to verify a cached public key type with namespace', () {
      var keyType = AtKey.getKeyType('cached:public:phone.buzz@bob');
      expect(keyType, equals(KeyType.cachedPublicKey));
    });

    test('Test to verify a shared key type with namespace', () {
      var keyType = AtKey.getKeyType('@alice:phone.wavi@bob');
      expect(keyType, equals(KeyType.sharedKey));
    });

    test('Test to verify a cached shared key type with namespace', () {
      var keyType = AtKey.getKeyType('cached:@alice:phone.buzz@bob');
      expect(keyType, equals(KeyType.cachedSharedKey));
    });

    test('Test to verify self key type with namespace', () {
      var keyType = AtKey.getKeyType('@bob:phone.buzz@bob');
      expect(keyType, equals(KeyType.selfKey));
    });
  });
}

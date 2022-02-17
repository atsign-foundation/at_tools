import 'package:at_commons/src/keystore/key_type.dart';
import 'package:at_commons/src/utils/at_key_regex_utils.dart';
import 'package:test/test.dart';

import 'test_keys.dart';

void main() {
  group('A group of tests to validate keyType', () {
    test('Tests to validate public key type', () {
      var keyTypeList = [];
      keyTypeList.add('public:@bob:phone.buzz@bob');
      keyTypeList.add('public:phone.buzz@bob');
      keyTypeList.add('public:@bob:p.b@bob');
      keyTypeList.add('public:pho_-ne.b@bob');
      keyTypeList.add('public:@bob💙:phone😀.buzz@bob💙');
      keyTypeList.add('public:phone.me@bob');

      for (var key in keyTypeList) {
        var type = RegexUtil.keyType(key);
        expect(type == KeyType.publicKey, true);
      }
    });

    test('Tests to validate private key types', () {
      var keyTypeList = [];
      keyTypeList.add("private:@bob:phone.buzz@bob");
      keyTypeList.add("private:phone.buzz@bob");
      keyTypeList.add("private:@bob:p.b@bob");
      keyTypeList.add("private:pho_-ne.b@bob");
      keyTypeList.add("private:@bob💙:phone😀.buzz@bob💙");

      for (var key in keyTypeList) {
        var type = RegexUtil.keyType(key);
        expect(type == KeyType.privateKey, true);
      }
    });

    test('Tests to validate self key types', () {
      var keyTypeList = [];
      keyTypeList.add("@bob:phone.buzz@bob");
      keyTypeList.add("phone.buzz@bob");
      keyTypeList.add("@bob:p.b@bob");
      keyTypeList.add("pho_-ne.b@bob");
      keyTypeList.add("@bob💙:phone😀.buzz@bob💙");

      for (var key in keyTypeList) {
        var type = RegexUtil.keyType(key);
        expect(type == KeyType.selfKey, true);
      }
    });

    test('Tests to validate shared key types', () {
      var keyTypeList = [];
      keyTypeList.add("@alice:phone.buzz@bob");
      keyTypeList.add("@alice:phone.buzz@bob");
      keyTypeList.add("@alice:p.b@bob");
      keyTypeList.add("@alice:pho_-ne.b@bob");
      keyTypeList.add("@alice💙:phone😀.buzz@bob💙");

      for (var key in keyTypeList) {
        var type = RegexUtil.keyType(key);
        expect(type == KeyType.sharedKey, true);
      }
    });

    test('Tests to validate cached public keys', () {
      var keyTypeList = [];
      keyTypeList.add("cached:public:@jagannadh:phone.buzz@jagannadh");
      keyTypeList.add("cached:public:phone.buzz@jagannadh");
      keyTypeList.add("cached:public:p.b@jagannadh");
      keyTypeList.add("cached:public:pho_-n________e.b@jagannadh");
      keyTypeList.add("cached:public:@jagannadh💙:phone😀.buzz@jagannadh💙");

      for (var key in keyTypeList) {
        var type = RegexUtil.keyType(key);
        expect(type == KeyType.cachedPublicKey, true);
      }
    });

    test('Tests to validate cached shared keys', () {
      var keyTypeList = [];
      keyTypeList.add(
          "cached:@sitaram0123456789012345678901234567890123456789012345:phone.buzz@jagannadh");
      keyTypeList.add("cached:@sitaram:phone.buzz@jagannadh");
      keyTypeList.add("cached:@sitaram:pho_-n________e.b@jagannadh");
      keyTypeList.add("cached:@sitaram💙:phone😀.buzz@jagannadh💙");

      for (var key in keyTypeList) {
        var type = RegexUtil.keyType(key);
        expect(type == KeyType.cachedSharedKey, true);
      }
    });
  });

  group('Public or private key regex match tests', () {
    test('Valid public keys', () {
      var pubKeys = TestKeys().validPublicKeys;
      for (var i = 0; i < pubKeys.length; i++) {
        expect(RegexUtil.matchAll(Regexes.publicKey, pubKeys[i]), true);
      }
    });

    test('Invalid public keys', () {
      var invalidPubKeys = TestKeys().invalidPublicKeys;
      for (var i = 0; i < invalidPubKeys.length; i++) {
        expect(RegexUtil.matchAll(Regexes.publicKey, invalidPubKeys[i]), false);
      }
    });

    test('Valid private keys', () {
      var privKeys = TestKeys().validPrivateKeys;
      for (var i = 0; i < privKeys.length; i++) {
        expect(RegexUtil.matchAll(Regexes.privateKey, privKeys[i]), true);
      }
    });

    test('Invalid private keys', () {
      var invalidPrivKeys = TestKeys().invalidPrivateKeys;
      for (var i = 0; i < invalidPrivKeys.length; i++) {
        print(invalidPrivKeys[i]);
        expect(
            RegexUtil.matchAll(Regexes.privateKey, invalidPrivKeys[i]), false);
      }
    });
  });

  group('Cached public keys regex match tests', () {
    test('Valid cached public keys', () {
      var cachedPubKeys = TestKeys().validCachedPublicKeys;
      for (var i = 0; i < cachedPubKeys.length; i++) {
        expect(RegexUtil.matchAll(Regexes.cachedPublicKey, cachedPubKeys[i]),
            true);
      }
    });

    test('Invalid cached public keys', () {
      var invalidCachedPubKeys = TestKeys().invalidCachedPublicKeys;
      for (var i = 0; i < invalidCachedPubKeys.length; i++) {
        expect(
            RegexUtil.matchAll(
                Regexes.cachedPublicKey, invalidCachedPubKeys[i]),
            false);
      }
    });
  });

  group('Self or hidden key regex match tests', () {
    test('Valid Self keys', () {
      var validSelfKeys = TestKeys().validSelfKeys;
      for (var i = 0; i < validSelfKeys.length; i++) {
        expect(RegexUtil.matchAll(Regexes.selfKey, validSelfKeys[i]), true);
      }
    });

    test('Invalid self keys', () {
      var invalidSelfKeys = TestKeys().invalidSelfKeys;
      for (var i = 0; i < invalidSelfKeys.length; i++) {
        expect(RegexUtil.matchAll(Regexes.selfKey, invalidSelfKeys[i]), false);
      }
    });

    group('Shared or cached key regex match tests', () {
      test('Valid shared keys', () {
        var validSharedKeys = TestKeys().validSharedKeys;
        for (var i = 0; i < validSharedKeys.length; i++) {
          expect(
              RegexUtil.matchAll(Regexes.sharedKey, validSharedKeys[i]), true);
        }
      });

      test('Invalid shared keys', () {
        var invalidSharedKeys = TestKeys().invalidSharedKeys;
        for (var i = 0; i < invalidSharedKeys.length; i++) {
          expect(RegexUtil.matchAll(Regexes.sharedKey, invalidSharedKeys[i]),
              false);
        }
      });

      test('Valid cached shared keys', () {
        var validCachedSharedKeys = TestKeys().validCachedSharedKeys;
        for (var i = 0; i < validCachedSharedKeys.length; i++) {
          print(validCachedSharedKeys[i]);
          expect(
              RegexUtil.matchAll(
                  Regexes.cachedSharedKey, validCachedSharedKeys[i]),
              true);
        }
      });

      test('Invalid cached shared keys', () {
        var invalidCachedSharedKeys = TestKeys().invalidCachedSharedKeys;
        for (var i = 0; i < invalidCachedSharedKeys.length; i++) {
          expect(
              RegexUtil.matchAll(
                  Regexes.cachedSharedKey, invalidCachedSharedKeys[i]),
              false);
        }
      });
    });
  });
}

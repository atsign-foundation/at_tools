import 'package:at_commons/at_commons.dart';
import 'package:at_commons/src/keystore/at_key_builder_impl.dart';
import 'package:at_commons/src/keystore/key_type.dart';
import 'package:at_commons/src/validators/at_key_validation.dart';
import 'package:at_commons/src/validators/at_key_validation_impl.dart';
import 'package:test/test.dart';

void main() {
  group('A group of positive test to construct a atKey', () {
    test('Test to verify a public key', () {
      var atKey = AtKey.fromString('public:phone@bob');
      expect(atKey.key, 'phone');
      expect(atKey.sharedBy, 'bob');
      expect(atKey.metadata!.isPublic, true);
      expect(atKey.metadata!.namespaceAware, false);
    });

    test('Test to verify protected key', () {
      var atKey = AtKey.fromString('@alice:phone@bob');
      expect(atKey.key, 'phone');
      expect(atKey.sharedBy, 'bob');
      expect(atKey.sharedWith, '@alice');
    });

    test('Test to verify private key', () {
      var atKey = AtKey.fromString('phone@bob');
      expect(atKey.key, 'phone');
      expect(atKey.sharedBy, 'bob');
    });

    test('Test to verify cached key', () {
      var atKey = AtKey.fromString('cached:@alice:phone@bob');
      expect(atKey.key, 'phone');
      expect(atKey.sharedBy, 'bob');
      expect(atKey.sharedWith, '@alice');
      expect(atKey.metadata!.isCached, true);
      expect(atKey.metadata!.namespaceAware, false);
    });

    test('Test to verify pkam private key', () {
      var atKey = AtKey.fromString(AT_PKAM_PRIVATE_KEY);
      expect(atKey.key, AT_PKAM_PRIVATE_KEY);
    });

    test('Test to verify pkam private key', () {
      var atKey = AtKey.fromString(AT_PKAM_PUBLIC_KEY);
      expect(atKey.key, AT_PKAM_PUBLIC_KEY);
    });

    test('Test to verify key with namespace', () {
      var atKey = AtKey.fromString('@alice:phone.buzz@bob');
      expect(atKey.key, 'phone');
      expect(atKey.sharedWith, '@alice');
      expect(atKey.sharedBy, 'bob');
      expect(atKey.metadata!.namespaceAware, true);
    });
  });

  group('A group a negative test cases', () {
    test('Test to verify invalid syntax exception is thrown', () {
      var key = 'phone.buzz';
      expect(
          () => AtKey.fromString(key),
          throwsA(predicate((dynamic e) =>
              e is InvalidSyntaxException &&
              e.message == '$key is not well-formed key')));
    });
  });

  group('A group of tests to validate the AtKey builder instances', () {
    test('Validate public key builder', () {
      PublicKeyBuilder publicKeyBuilder =
          AtKey.public('phone', namespace: 'wavi');
      expect(publicKeyBuilder, isA<PublicKeyBuilder>());
    });

    test('Validate the shared key builder', () {
      SharedKeyBuilder sharedKeyBuilder =
          AtKey.shared('phone', namespace: 'wavi')..sharedWith('@bob');
      expect(sharedKeyBuilder, isA<SharedKeyBuilder>());
    });

    test('Validate the self key builder', () {
      SelfKeyBuilder selfKeyBuilder = AtKey.self('phone', namespace: 'wavi');
      expect(selfKeyBuilder, isA<SelfKeyBuilder>());
    });

    test('Validate the hidden key builder', () {
      PrivateKeyBuilder hiddenKeyBuilder =
          AtKey.private('phone', namespace: 'wavi');
      expect(hiddenKeyBuilder, isA<PrivateKeyBuilder>());
    });
  });

  group('A group of tests to validate the AtKey instances', () {
    test('Test to verify the public key', () {
      AtKey atKey = AtKey.public('phone', namespace: 'wavi').build();
      expect(atKey, isA<PublicKey>());
    });

    test('Test to verify the shared key', () {
      AtKey atKey = (AtKey.shared(
        'image',
        namespace: 'wavi',
      )..sharedWith('bob'))
          .build();
      expect(atKey, isA<SharedKey>());
    });

    test('Test to verify the self key', () {
      AtKey selfKey = AtKey.self('phone', namespace: 'wavi').build();
      expect(selfKey, isA<SelfKey>());
    });

    test('Test to verify the hidden key', () {
      AtKey selfKey = AtKey.private('phone', namespace: 'wavi').build();
      expect(selfKey, isA<PrivateKey>());
    });
  });

  group('A group of negative tests to validate AtKey', () {
    test('Test to verify AtException is thrown when key is empty', () {
      expect(
          () => (AtKey.public('', namespace: 'wavi')).build(),
          throwsA(predicate((dynamic e) =>
              e is AtException && e.message == 'Key cannot be empty')));
    });

    test('Test to verify AtException is thrown when namespace is empty', () {
      expect(
          () => (AtKey.public('phone', namespace: '')).build(),
          throwsA(predicate((dynamic e) =>
              e is AtException && e.message == 'Namespace cannot be empty')));
    });

    test(
        'Test to verify AtException is thrown when sharedWith is populated for sharedKey',
        () {
      expect(
          () => (AtKey.shared('phone', namespace: 'wavi')).build(),
          throwsA(predicate((dynamic e) =>
              e is AtException && e.message == 'sharedWith cannot be empty')));
    });
  });

  group('Test public key creation', () {
    test('Test key and namespace with no ttl and ttb', () {
      AtKey atKey = AtKey.public('phone', namespace: 'wavi').build();
      expect(atKey.key, equals('phone'));
      expect(atKey.namespace, equals('wavi'));
      expect(atKey.metadata!.ttl, equals(null));
      expect(atKey.metadata!.ttb, equals(null));
      expect(atKey.metadata!.isPublic, equals(true));
      expect(atKey.metadata!.isBinary, equals(false));
      expect(atKey.metadata!.isCached, equals(false));
    });

    test('Test key and namespace with ttl and ttb', () {
      AtKey atKey = (AtKey.public('phone', namespace: 'wavi')
            ..timeToLive(1000)
            ..timeToBirth(2000))
          .build();

      expect(atKey.key, equals('phone'));
      expect(atKey.namespace, equals('wavi'));
      expect(atKey.metadata!.ttl, equals(1000));
      expect(atKey.metadata!.ttb, equals(2000));
      expect(atKey.metadata!.isPublic, equals(true));
      expect(atKey.metadata!.isPublic, equals(true));
      expect(atKey.metadata!.isBinary, equals(false));
      expect(atKey.metadata!.isCached, equals(false));
    });
  });

  group('Test shared key creation', () {
    test('Test shared key without caching', () {
      AtKey atKey =
          (AtKey.shared('phone', namespace: 'wavi')..sharedWith('bob')).build();

      expect(atKey.key, equals('phone'));
      expect(atKey.namespace, equals('wavi'));
      expect(atKey.sharedWith, equals('bob'));
      expect(atKey.metadata!.ttl, equals(null));
      expect(atKey.metadata!.ttb, equals(null));
      expect(atKey.metadata!.isPublic, equals(false));
      expect(atKey.metadata!.isBinary, equals(false));
      expect(atKey.metadata!.isCached, equals(false));
    });

    test('Test shared key with caching', () {
      AtKey atKey = (AtKey.shared('phone', namespace: 'wavi')
            ..sharedWith('bob')
            ..cache(1000, true))
          .build();

      expect(atKey.key, equals('phone'));
      expect(atKey.namespace, equals('wavi'));
      expect(atKey.sharedWith, equals('bob'));
      expect(atKey.metadata!.ttr, equals(1000));
      expect(atKey.metadata!.ccd, equals(true));
      expect(atKey.metadata!.ttl, equals(null));
      expect(atKey.metadata!.ttb, equals(null));
      expect(atKey.metadata!.isPublic, equals(false));
      expect(atKey.metadata!.isBinary, equals(false));
      expect(atKey.metadata!.isCached, equals(true));
    });
  });

  group('A group of tests to validate the public keys', () {
    test('validate a public key with namespace', () {
      var validationResult = AtKeyValidators.get()
          .validate('public:phone.me@alice', ValidationContext('@alice'));
      expect(validationResult.isValid, true);
    });

    test('validate a public key with setting validation context', () {
      var validationResult = AtKeyValidators.get().validate(
          'public:phone.me@alice',
          ValidationContext('@alice')..type = KeyType.publicKey);
      expect(validationResult.isValid, true);
    });
  });

  group('A group of tests to validate the self keys', () {
    test('validate a self key with namespace', () {
      var validationResult = AtKeyValidators.get()
          .validate('phone.me@alice', ValidationContext('@alice'));
      expect(validationResult.isValid, true);
    });

    test('validate a self key with setting validation context', () {
      var validationResult = AtKeyValidators.get().validate('phone.me@alice',
          ValidationContext('@alice')..type = KeyType.selfKey);
      expect(validationResult.isValid, true);
    });

    test('validate a self key with sharedWith populated', () {
      var validationResult = AtKeyValidators.get().validate(
          '@alice:phone.me@alice',
          ValidationContext('@alice')..type = KeyType.selfKey);
      expect(validationResult.isValid, true);
    });
  });

  group('A group of tests to validate the shared keys', () {
    test('validate a shared key with namespace', () {
      var validationResult = AtKeyValidators.get()
          .validate('@bob:phone.me@alice', ValidationContext('@alice'));
      expect(validationResult.isValid, true);
    });

    test('validate a shared key with setting validation context', () {
      var validationResult = AtKeyValidators.get().validate(
          '@bob:phone.me@alice',
          ValidationContext('@alice')..type = KeyType.sharedKey);
      expect(validationResult.isValid, true);
    });

    test('Verify a shared key without sharedWith populated throws error', () {
      var validationResult = AtKeyValidators.get().validate('phone.me@alice',
          ValidationContext('@alice')..type = KeyType.sharedKey);
      expect(validationResult.isValid, false);
    });
  });

  group('A group of tests to validate the cached shared keys', () {
    test('validate a cached shared key with namespace', () {
      var validationResult = AtKeyValidators.get().validate(
          'cached:@bob:phone.me@alice',
          ValidationContext('@alice')..atSign = '@bob');
      expect(validationResult.isValid, true);
    });

    test('validate a cached shared key with setting validation context', () {
      var validationResult = AtKeyValidators.get().validate(
          'cached:@bob:phone.me@alice',
          ValidationContext('@bob')..type = KeyType.cachedSharedKey);
      expect(validationResult.isValid, true);
    });

    test(
        'validate a cached shared key throws error when owner is currentAtSign',
        () {
      var validationResult = AtKeyValidators.get().validate(
          'cached:@bob:phone.me@alice',
          ValidationContext('@alice')..type = KeyType.cachedSharedKey);
      expect(validationResult.isValid, false);
      expect(validationResult.failureReason,
          'Owner of the key alice should not be same as the the current @sign alice for a cached key');
    });

    test('Verify a cached shared key without sharedWith populated throws error',
        () {
      var validationResult = AtKeyValidators.get().validate(
          'cached:phone.me@alice',
          ValidationContext('@alice')..type = KeyType.cachedSharedKey);
      expect(validationResult.isValid, false);
    });
  });

  group('A group of tests to validate the cached public keys', () {
    test('validate a cached public key with namespace', () {
      var validationResult = AtKeyValidators.get().validate(
          'cached:public:@bob:phone.me@alice', ValidationContext('@bob'));
      expect(validationResult.isValid, true);
    });

    test('validate a cached shared key with setting validation context', () {
      var validationResult = AtKeyValidators.get().validate(
          'cached:@bob:phone.me@alice',
          ValidationContext('@bob')..type = KeyType.cachedSharedKey);
      expect(validationResult.isValid, true);
    });

    test(
        'validate a cached shared key throws error when owner is currentAtSign',
        () {
      var validationResult = AtKeyValidators.get().validate(
          'cached:@bob:phone.me@alice',
          ValidationContext('@alice')..type = KeyType.cachedSharedKey);
      expect(validationResult.isValid, false);
      expect(validationResult.failureReason,
          'Owner of the key alice should not be same as the the current @sign alice for a cached key');
    });

    test('Verify a cached shared key without sharedWith populated throws error',
        () {
      var validationResult = AtKeyValidators.get().validate(
          'cached:phone.me@alice',
          ValidationContext('@alice')..type = KeyType.cachedSharedKey);
      expect(validationResult.isValid, false);
    });
  });

  group('A group of tests to validate the reserved keys', () {
    test('Test to verify self encryption key reserved key is not created', () {
      var validationResult = AtKeyValidators.get().validate(
          '@bob:shared_key.me@alice',
          ValidationContext('@alice')..type = KeyType.sharedKey);
      expect(validationResult.isValid, false);
      expect(validationResult.failureReason, 'Reserved key cannot be created');
    });

    test('Test to verify creation of encryption public key fails', () {
      var validationResult = AtKeyValidators.get().validate(
          'public:publickey.me@alice',
          ValidationContext('@alice')..type = KeyType.publicKey);
      expect(validationResult.isValid, false);
      expect(validationResult.failureReason, 'Reserved key cannot be created');
    });

    test('Test to verify creation of encryption public key fails', () {
      var validationResult = AtKeyValidators.get().validate(
          'signing_privatekey.me@alice',
          ValidationContext('@alice')..type = KeyType.selfKey);
      expect(validationResult.isValid, false);
      expect(validationResult.failureReason, 'Reserved key cannot be created');
    });
  });

  group('A group of tests to verify toString method', () {
    // public keys
    test('A test to verify a public key creation', () {
      var atKey = AtKey()
        ..key = 'phone'
        ..sharedBy = '@alice'
        ..metadata = (Metadata()..isPublic = true);
      expect('public:phone@alice', atKey.toString());
    });
    test(
        'A test to verify a public-key creation on a public key factory method',
        () {
      var atKey = PublicKey()
        ..key = 'phone'
        ..sharedBy = '@alice';
      expect('public:phone@alice', atKey.toString());
    });
    // Shared keys
    test('A test to verify a sharedWith key creation', () {
      var atKey = AtKey()
        ..key = 'phone'
        ..sharedWith = '@bob'
        ..sharedBy = '@alice';
      expect('@bob:phone@alice', atKey.toString());
    });
    test(
        'A test to verify a sharedWith key creation with static factory method',
        () {
      var atKey = SharedKey()
        ..key = 'phone'
        ..sharedWith = '@bob'
        ..sharedBy = '@alice';
      expect('@bob:phone@alice', atKey.toString());
    });
    // Self keys
    test('A test to verify a self key creation', () {
      var atKey = AtKey()
        ..key = 'phone'
        ..sharedWith = '@alice'
        ..sharedBy = '@alice';
      expect('@alice:phone@alice', atKey.toString());
    });
    test('A test to verify a self key creation with static factory method', () {
      var atKey = SelfKey()
        ..key = 'phone'
        ..sharedWith = '@alice'
        ..sharedBy = '@alice';
      expect('@alice:phone@alice', atKey.toString());
    });
    test('Verify a self key creation without sharedWith using static factory',
        () {
      var atKey = SelfKey()
        ..key = 'phone'
        ..sharedBy = '@alice';
      expect('phone@alice', atKey.toString());
    });
    test('Verify a self key creation without sharedWith', () {
      var atKey = AtKey()
        ..key = 'phone'
        ..sharedBy = '@alice';
      expect('phone@alice', atKey.toString());
    });
    // Cached keys
    test('Verify a cached key creation', () {
      var atKey = AtKey()
        ..key = 'phone'
        ..sharedWith = '@bob'
        ..sharedBy = '@alice'
        ..metadata = (Metadata()..isCached = true);
      expect('cached:@bob:phone@alice', atKey.toString());
    });
    test('Verify a public cached key creation', () {
      var atKey = AtKey()
        ..key = 'phone'
        ..sharedBy = '@alice'
        ..metadata = (Metadata()
          ..isCached = true
          ..isPublic = true);
      expect('cached:public:phone@alice', atKey.toString());
    });
    //Private keys
    test('Verify a privatekey creation using static factory method', () {
      var atKey = PrivateKey()..key = 'at_secret';
      expect('privatekey:at_secret', atKey.toString());
    });
    test('Verify a privatekey creation', () {
      var atKey = AtKey()..key = 'privatekey:at_secret';
      expect('privatekey:at_secret', atKey.toString());
    });
  });
}

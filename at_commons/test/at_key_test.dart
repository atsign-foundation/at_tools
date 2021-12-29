import 'package:at_commons/at_commons.dart';
import 'package:at_commons/src/keystore/at_key_builder_impl.dart';
import 'package:test/expect.dart';
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
      PublicKeyBuilder publicKeyBuilder = AtKey.public('phone', 'wavi');
      expect(publicKeyBuilder, isA<PublicKeyBuilder>());
    });

    test('Validate the shared key builder', () {
      SharedKeyBuilder sharedKeyBuilder = AtKey.shared('phone', 'wavi')
        ..sharedWith('@bob');
      expect(sharedKeyBuilder, isA<SharedKeyBuilder>());
    });

    test('Validate the self key builder', () {
      SelfKeyBuilder selfKeyBuilder = AtKey.self('phone', 'wavi');
      expect(selfKeyBuilder, isA<SelfKeyBuilder>());
    });

    test('Validate the hidden key builder', () {
      HiddenKeyBuilder hiddenKeyBuilder = AtKey.hidden('phone', 'wavi');
      expect(hiddenKeyBuilder, isA<HiddenKeyBuilder>());
    });
  });

  group('A group of tests to validate the AtKey instances', () {
    test('Test to verify the public key', () {
      AtKey atKey = AtKey.public('phone', 'wavi').build();
      expect(atKey, isA<PublicKey>());
    });

    test('Test to verify the shared key', () {
      AtKey atKey = (AtKey.shared('image', 'wavi', valueType: ValueType.binary)
            ..sharedWith('bob'))
          .build();
      expect(atKey, isA<SharedKey>());
    });

    test('Test to verify the self key', () {
      AtKey selfKey = AtKey.self('phone', 'wavi').build();
      expect(selfKey, isA<SelfKey>());
    });

    test('Test to verify the hidden key', () {
      AtKey selfKey = AtKey.hidden('phone', 'wavi').build();
      expect(selfKey, isA<HiddenKey>());
    });
  });

  group('A group of negative tests to validate AtKey', () {
    test('Test to verify AtException is thrown when key is empty', () {
      expect(
          () => (AtKey.public('', 'wavi')).build(),
          throwsA(predicate((dynamic e) =>
              e is AtException && e.message == 'Key cannot be empty')));
    });

    test('Test to verify AtException is thrown when namespace is empty', () {
      expect(
          () => (AtKey.public('phone', ' ')).build(),
          throwsA(predicate((dynamic e) =>
              e is AtException && e.message == 'Namespace cannot be empty')));
    });

    test(
        'Test to verify AtException is thrown when sharedWith is populated for sharedKey',
        () {
      expect(
          () => (AtKey.shared('phone', 'wavi')).build(),
          throwsA(predicate((dynamic e) =>
              e is AtException && e.message == 'sharedWith cannot be empty')));
    });
  });

  group('Test public key creation', () {
    test('Test key and namespace with no ttl and ttb', () {
      AtKey atKey = AtKey.public('phone', 'wavi').build();
      expect(atKey.key, equals('phone'));
      expect(atKey.namespace, equals('wavi'));
      expect(atKey.metadata!.ttl, equals(null));
      expect(atKey.metadata!.ttb, equals(null));
      expect(atKey.metadata!.isPublic, equals(true));
      expect(atKey.metadata!.isBinary, equals(false));
      expect(atKey.metadata!.isCached, equals(false));
    });

    test('Test key and namespace with ttl and ttb', () {
      AtKey atKey = (AtKey.public('phone', 'wavi')
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

    test('Test binary public data', () {
      AtKey atKey = AtKey.public('image', 'wavi', valueType: ValueType.binary).build();

      expect(atKey.key, equals('image'));
      expect(atKey.namespace, equals('wavi'));
      expect(atKey.metadata!.ttl, equals(null));
      expect(atKey.metadata!.ttb, equals(null));
      expect(atKey.metadata!.isPublic, equals(true));
      expect(atKey.metadata!.isBinary, equals(true));
      expect(atKey.metadata!.isCached, equals(false));
    });
  });

  group('Test shared key creation', () {
    test('Test shared key without caching', () {
      AtKey atKey = (AtKey.shared('phone', 'wavi')
        ..sharedWith('bob'))
          .build();

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

      AtKey atKey = (AtKey.shared('phone', 'wavi')
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

    test('Test binary shared key', () {

      AtKey atKey = (AtKey.shared('image', 'wavi', valueType: ValueType.binary)
        ..sharedWith('bob'))
          .build();

      expect(atKey.key, equals('image'));
      expect(atKey.namespace, equals('wavi'));
      expect(atKey.metadata!.ttl, equals(null));
      expect(atKey.metadata!.ttb, equals(null));
      expect(atKey.metadata!.isPublic, equals(false));
      expect(atKey.metadata!.isBinary, equals(true));
      expect(atKey.metadata!.isCached, equals(false));
    });
  });
}

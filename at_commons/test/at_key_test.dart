import 'package:at_commons/at_commons.dart';
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
}

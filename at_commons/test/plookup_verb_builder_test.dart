import 'package:at_commons/at_builders.dart';
import 'package:test/test.dart';

void main() {
  group('A group of lookup verb builder tests', () {
    test('verify simple plookup command', () {
      var updateBuilder = PLookupVerbBuilder()
        ..atKey = 'phone'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommand(), 'plookup:phone@alice\n');
    });
    test('verify plookup meta command', () {
      var updateBuilder = PLookupVerbBuilder()
        ..operation = 'meta'
        ..atKey = 'email'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommand(), 'plookup:meta:email@alice\n');
    });

    test('verify plookup all command', () {
      var updateBuilder = PLookupVerbBuilder()
        ..operation = 'all'
        ..atKey = 'email'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommand(), 'plookup:all:email@alice\n');
    });

    test('verify plookup bypass cache command', () {
      var updateBuilder = PLookupVerbBuilder()
        ..byPassCache = true
        ..atKey = 'email'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommand(),
          'plookup:bypassCache:true:email@alice\n');
    });
  });
}

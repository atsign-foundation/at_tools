import 'package:at_commons/at_builders.dart';
import 'package:test/test.dart';

void main() {
  group('A group of lookup verb builder tests', () {
    test('verify simple lookup command', () {
      var updateBuilder = LookupVerbBuilder()
        ..atKey = 'phone'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommand(), 'lookup:phone@alice\n');
    });
    test('verify lookup meta command', () {
      var updateBuilder = LookupVerbBuilder()
        ..operation = 'meta'
        ..atKey = 'email'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommand(), 'lookup:meta:email@alice\n');
    });

    test('verify lookup all command', () {
      var updateBuilder = LookupVerbBuilder()
        ..operation = 'all'
        ..atKey = 'email'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommand(), 'lookup:all:email@alice\n');
    });

    test('verify lookup bypass cache command', () {
      var updateBuilder = LookupVerbBuilder()
        ..byPassCache = true
        ..atKey = 'email'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommand(),
          'lookup:bypass_cache:true:email@alice\n');
    });
  });
}

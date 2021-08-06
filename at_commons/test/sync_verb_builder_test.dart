import 'package:at_commons/at_builders.dart';
import 'package:at_commons/src/verb/sync_verb_builder.dart';
import 'package:test/test.dart';

void main() {
  test('build sync verb command with defaults values', () {
    SyncVerbBuilder syncVerbBuilder = SyncVerbBuilder()..commitId = '-1';
    String command = syncVerbBuilder.buildCommand();
    expect(command, 'sync:-1\n');
    RegExp regex = RegExp(VerbSyntax.sync);
    command = command.replaceAll('\n', '');
    assert(regex.hasMatch(command));
  });

  test('build sync verb command with regex', () {
    SyncVerbBuilder syncVerbBuilder = SyncVerbBuilder()
      ..regex = '.buzz'
      ..commitId = '-1';
    String command = syncVerbBuilder.buildCommand();
    expect(command, 'sync:-1:.buzz\n');
    RegExp regex = RegExp(VerbSyntax.sync);
    command = command.replaceAll('\n', '');
    assert(regex.hasMatch(command));
  });

  test('build sync verb command with commitId and regex', () {
    SyncVerbBuilder syncVerbBuilder = SyncVerbBuilder()
      ..commitId = '3'
      ..regex = '.buzz';
    String command = syncVerbBuilder.buildCommand();
    expect(command, 'sync:3:.buzz\n');
    RegExp regex = RegExp(VerbSyntax.sync);
    command = command.replaceAll('\n', '');
    assert(regex.hasMatch(command));
  });

  test('build sync stream verb command with regex', () {
    SyncVerbBuilder syncVerbBuilder = SyncVerbBuilder()
      ..commitId = '3'
      ..regex = '.buzz'
      ..isStream = true;
    String command = syncVerbBuilder.buildCommand();
    expect(command, 'sync:stream:3:.buzz\n');
    RegExp regex = RegExp(VerbSyntax.syncStream);
    command = command.replaceAll('\n', '');
    assert(regex.hasMatch(command));
  });

  test('build sync stream verb command', () {
    SyncVerbBuilder syncVerbBuilder = SyncVerbBuilder()
      ..commitId = '3'
      ..isStream = true;
    String command = syncVerbBuilder.buildCommand();
    expect(command, 'sync:stream:3\n');
    RegExp regex = RegExp(VerbSyntax.syncStream);
    command = command.replaceAll('\n', '');
    assert(regex.hasMatch(command));
  });

  test('build sync stream verb command', () {
    SyncVerbBuilder syncVerbBuilder = SyncVerbBuilder()
      ..isStream = true
      ..commitId = '-1';
    String command = syncVerbBuilder.buildCommand();
    expect(command, 'sync:stream:-1\n');
    RegExp regex = RegExp(VerbSyntax.syncStream);
    command = command.replaceAll('\n', '');
    assert(regex.hasMatch(command));
  });
}

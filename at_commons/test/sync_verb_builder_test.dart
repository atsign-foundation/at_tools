import 'package:at_commons/at_builders.dart';
import 'package:at_commons/src/verb/sync_verb_builder.dart';
import 'package:test/test.dart';

void main() {
  test('build sync verb command with defaults values', () {
    var syncVerbBuilder = SyncVerbBuilder()..commitId = -1;
    var command = syncVerbBuilder.buildCommand();
    expect(command, 'sync:-1\n');
    var regex = RegExp(VerbSyntax.sync);
    command = command.replaceAll('\n', '');
    assert(regex.hasMatch(command));
  });

  test('build sync verb command with regex', () {
    var syncVerbBuilder = SyncVerbBuilder()
      ..regex = '.buzz'
      ..commitId = -1;
    var command = syncVerbBuilder.buildCommand();
    expect(command, 'sync:-1:.buzz\n');
    var regex = RegExp(VerbSyntax.sync);
    command = command.replaceAll('\n', '');
    assert(regex.hasMatch(command));
  });

  test('build sync verb command with commitId and regex', () {
    var syncVerbBuilder = SyncVerbBuilder()
      ..commitId = 3
      ..regex = '.buzz';
    var command = syncVerbBuilder.buildCommand();
    expect(command, 'sync:3:.buzz\n');
    var regex = RegExp(VerbSyntax.sync);
    command = command.replaceAll('\n', '');
    assert(regex.hasMatch(command));
  });

  test('build sync stream verb command with regex', () {
    var syncVerbBuilder = SyncVerbBuilder()
      ..commitId = 3
      ..regex = '.buzz'
      ..isStream = true;
    var command = syncVerbBuilder.buildCommand();
    expect(command, 'sync:stream:3:.buzz\n');
    var regex = RegExp(VerbSyntax.syncStream);
    command = command.replaceAll('\n', '');
    assert(regex.hasMatch(command));
  });

  test('build sync stream verb command', () {
    var syncVerbBuilder = SyncVerbBuilder()
      ..commitId = 3
      ..isStream = true;
    var command = syncVerbBuilder.buildCommand();
    expect(command, 'sync:stream:3\n');
    var regex = RegExp(VerbSyntax.syncStream);
    command = command.replaceAll('\n', '');
    assert(regex.hasMatch(command));
  });

  test('build sync stream verb command', () {
    var syncVerbBuilder = SyncVerbBuilder()
      ..isStream = true
      ..commitId = -1;
    var command = syncVerbBuilder.buildCommand();
    expect(command, 'sync:stream:-1\n');
    var regex = RegExp(VerbSyntax.syncStream);
    command = command.replaceAll('\n', '');
    assert(regex.hasMatch(command));
  });
}

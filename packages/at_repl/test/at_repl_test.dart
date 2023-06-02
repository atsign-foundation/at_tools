import 'package:at_client/at_client.dart';
import 'package:at_repl/at_repl.dart';
import 'package:at_utils/at_logger.dart';
import 'package:at_commons/src/verb/scan_verb_builder.dart';
import 'package:test/test.dart';

void main() async {
  final String atSign = '@chess69';
  REPL repl = REPL(atSign, rootUrl: "root.atsign.org:64");
  AtSignLogger.root_level = 'warning';
  group("Test REPL functions", () {
    test("test Authenticate", () async {
      final bool authenticated = await repl.authenticate();
      expect(repl.atClient, AtClientManager.getInstance().atClient);
    });

    test("test repl Atsign", () {
      expect(atSign, repl.atClient.getCurrentAtSign());
    });

    test("test synching", () async {
      await repl.syncSecondary();
      expect(await repl.atClient.syncService.isInSync(), true);
    });

    test('test executeCommand', () async {
      ScanVerbBuilder scanVerbBuilder = ScanVerbBuilder()
        ..showHiddenKeys = false
        ..sharedBy = '@chess69';

      var verbResult =
          await AtClientManager.getInstance().atClient.getRemoteSecondary()!.executeVerb(scanVerbBuilder, sync: true);
      var commandResult = await repl.executeCommand("scan\n");
      expect(commandResult, verbResult);
    });
  });
}

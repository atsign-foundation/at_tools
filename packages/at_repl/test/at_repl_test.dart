import 'package:at_client/at_client.dart';
import 'package:at_repl/src/at_repl.dart';
import 'package:at_utils/at_logger.dart';
import 'package:at_commons/src/verb/scan_verb_builder.dart';
import 'package:test/test.dart';

void main() async {
  final String atSign = '@chess69';
  REPL repl = REPL(atSign, rootUrl: "root.atsign.org:64");
  AtSignLogger.root_level = 'warning';
  final String namespace = 'impressed1';
  // ignore: unused_local_variable
  final bool authenticated = await repl.authenticate();

  group("Test REPL protocol functionality", () {
    test("test Authenticate", () async {
      expect(repl.atClient, AtClientManager.getInstance().atClient);
    });

    test("test repl Atsign", () {
      expect(atSign, repl.atClient.getCurrentAtSign());
    });

    test("test synching", () async {
      repl.atClient.syncService.sync();
      await Future.delayed(Duration(seconds: 5));
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

  group("Test REPL functions with public keys", () {
    //BAD Path >:(
    final bool enforceNamespace = true;
    test("Test Put with namespaces", () async {
      List<String> args = ["put", "public:demotest$atSign", "initial"];
      try {
        await repl.put(args, enforceNamespace);
      } catch (e) {
        expect(e.runtimeType, AtKeyException);
      }
    });
    test("Test Get with namespaces", () async {
      List<String> args = ["put", "public:demotest$atSign"];
      try {
        await repl.getKey(args);
      } catch (e) {
        expect(e.runtimeType, AtKeyNotFoundException);
      }
    });
    test("Test Update with namespaces", () async {
      List<String> args = ["put", "public:demotest$atSign", "updated"];
      try {
        await repl.put(args, enforceNamespace);
      } catch (e) {
        expect(e.runtimeType, AtKeyException);
      }
    });

    //Happy Path :)
    test("Test Put with namespaces", () async {
      List<String> args = ["put", "public:demotest.$namespace$atSign", "initial"];
      String result = await repl.put(args, enforceNamespace);
      expect(result.isNotEmpty, true);
    });
    test("Test Get with namespaces", () async {
      List<String> args = ["put", "public:demotest.$namespace$atSign"];
      String result = await repl.getKey(args);
      expect(result, "initial");
    });
    test("Test Update with namespaces", () async {
      List<String> args = ["put", "public:demotest.$namespace$atSign", "updated"];
      String result = await repl.put(args, enforceNamespace);
      expect(result.isNotEmpty, true);
    });
  });

  group("Test REPL functions with shared keys", () {
    final bool enforceNamespace = true;
    test("Test Put with namespaces", () async {
      List<String> args = ["put", "@chess69_lovely:demotest.$namespace$atSign", "initial"];
      String result = await repl.put(args, enforceNamespace);
      expect(result.isNotEmpty, true);
    });
    test("Test Get with namespaces", () async {
      List<String> args = ["put", "public:demotest.$namespace$atSign"];
      String result = await repl.getKey(args);
      expect(result, "initial");
    });
    test("Test Update with namespaces", () async {
      List<String> args = ["put", "public:demotest.$namespace$atSign", "updated"];
      String result = await repl.put(args, enforceNamespace);
      expect(result.isNotEmpty, true);
    });
  });
}

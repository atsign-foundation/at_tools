import 'package:at_client/at_client.dart';
import 'package:at_repl/src/at_repl.dart';
import 'package:at_utils/at_logger.dart';
import 'package:at_commons/src/verb/scan_verb_builder.dart';
import 'package:build_verify/build_verify.dart';
import 'package:test/test.dart';

void main() async {
  final String atSign = '@chess69';
  REPL repl = REPL(atSign, rootUrl: "root.atsign.org:64");
  AtSignLogger.root_level = 'warning';
  final bool authenticated = await repl.authenticate();

  test("Test Build", expectBuildClean);

  group("Test REPL protocol functionality", () {
    test("test Authenticate", () async {
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

  group("Test Exceptions REPL functions enforcing Namespaces", () {
    //BAD Path >:(
    final bool enforceNamespace = true;
    test("Test Put with namespaces", () async {
      List<String> args = ["put", "public:demotest@chess69", "initial"];
      try {
        await repl.put(args, enforceNamespace);
      } catch (e) {
        expect(e.runtimeType, AtKeyException);
      }
    });
    test("Test Get with namespaces", () async {
      List<String> args = ["put", "public:demotest@chess69"];
      try {
        await repl.getKey(args, enforceNamespace);
      } catch (e) {
        expect(e.runtimeType, AtKeyNotFoundException);
      }
    });
    test("Test Update with namespaces", () async {
      List<String> args = ["put", "public:demotest@chess69", "updated"];
      try {
        await repl.put(args, enforceNamespace);
      } catch (e) {
        expect(e.runtimeType, AtKeyException);
      }
    });
  });

  group("Test REPL functions enforcing Namespaces", () {
    //Happy Path :)
    final bool enforceNamespace = true;
    test("Test Put with namespaces", () async {
      List<String> args = ["put", "public:demotest.soccer0@chess69", "initial"];
      String result = await repl.put(args, enforceNamespace);
      expect(result.isNotEmpty, true);
    });
    test("Test Get with namespaces", () async {
      List<String> args = ["put", "public:demotest.soccer0@chess69"];
      String result = await repl.getKey(args, enforceNamespace);
      expect(result.isNotEmpty, true);
    });
    test("Test Update with namespaces", () async {
      List<String> args = ["put", "public:demotest.soccer0@chess69", "updated"];
      String result = await repl.put(args, enforceNamespace);
      expect(result.isNotEmpty, true);
    });
    test("Test Delete with namespaces", () async {
      List<String> args = ["put", "public:demotest.soccer0@chess69"];
      String result = await repl.delete(args, enforceNamespace);
      expect(result.isNotEmpty, true);
    });
  });
}

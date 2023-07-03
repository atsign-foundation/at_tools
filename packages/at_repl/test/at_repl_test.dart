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

    test('test executeCommand', () async {
      ScanVerbBuilder scanVerbBuilder = ScanVerbBuilder()
        ..showHiddenKeys = false
        ..sharedBy = '@chess69';

      var verbResult = await AtClientManager.getInstance()
          .atClient
          .getRemoteSecondary()!
          .executeVerb(scanVerbBuilder, sync: true);
      var commandResult = await repl.executeCommand("scan\n");
      expect(commandResult, verbResult);
    });
  });

  group("Test REPL functions with public keys", () {
    //BAD Path >:(
    final bool enforceNamespace = true;
    test("Put Exceptions", () async {
      List<String> args = ["put", "public:demotest$atSign", "initial"];
      try {
        await repl.put(args, enforceNamespace);
      } catch (e) {
        expect(e.runtimeType, AtKeyException);
      }
    });
    test("Get Exceptions", () async {
      List<String> args = ["put", "public:demotest$atSign"];
      try {
        await repl.getKey(args);
      } catch (e) {
        expect(e.runtimeType, AtKeyNotFoundException);
      }
    });
    test("Update Exceptions", () async {
      List<String> args = ["put", "public:demotest$atSign", "updated"];
      try {
        await repl.put(args, enforceNamespace);
      } catch (e) {
        expect(e.runtimeType, AtKeyException);
      }
    });

    //Happy Path :)
    test("Put", () async {
      List<String> args = [
        "put",
        "public:demotest.$namespace$atSign",
        "initial"
      ];
      String result = await repl.put(args, enforceNamespace);
      expect(result.isNotEmpty, true);
    });
    test("Get", () async {
      List<String> args = ["get", "public:demotest.$namespace$atSign"];
      String result = await repl.getKey(args);
      expect(result, " => initial");
    });
    test("Update", () async {
      List<String> args = [
        "put",
        "public:demotest.$namespace$atSign",
        "updated"
      ];
      String result = await repl.put(args, enforceNamespace);
      expect(result.isNotEmpty, true);
    });
    test("Get after update", () async {
      List<String> args = ["get", "public:demotest.$namespace$atSign"];
      String result = await repl.getKey(args);
      expect(result, " => updated");
    });

    test("Delete", () async {
      List<String> args = ["delete", "public:demotest.$namespace$atSign"];
      String result = await repl.delete(args);
      expect(result, " => true");
    });
  });

  group("Test REPL functions with shared keys", () {
    final bool enforceNamespace = true;
    test("Test Put", () async {
      List<String> args = [
        "put",
        "@chess69lovely:demotest.$namespace$atSign",
        "initial"
      ];
      String result = await repl.put(args, enforceNamespace);
      expect(result.isNotEmpty, true);
    });
    test("Test Get from another atsign", () async {
      List<String> args = ["get", "@chess69lovely:demotest.$namespace$atSign"];
      String result = await repl.getKey(args);
      expect(result, " => initial");
    });
    test("Test Update from another atsign", () async {
      List<String> args = [
        "put",
        "@chess69lovely:demotest.$namespace$atSign",
        "updated"
      ];
      String result = await repl.put(args, enforceNamespace);
      expect(result.isNotEmpty, true);
    });
    test("Test Get after update", () async {
      List<String> args = ["get", "@chess69lovely:demotest.$namespace$atSign"];
      String result = await repl.getKey(args);
      expect(result, " => updated");
    });

    test("Test Delete", () async {
      List<String> args = [
        "delete",
        "$atSign:demotest.$namespace@chess69lovely"
      ];
      String result = await repl.delete(args);
      expect(result, " => true");
    });
    test("Test get symmetric shared keys", () async {
      List<String> args = ["get", "shared_key.$namespace@$atSign"];
      try {
        await repl.getKey(args);
      } catch (e) {
        expect(e.runtimeType, AtKeyException);
      }
    });

    test("Test put symmetric shared keys", () async {
      List<String> args = ["put", "shared_key.$namespace@$atSign"];
      try {
        await repl.getKey(args);
      } catch (e) {
        expect(e.runtimeType, AtKeyException);
      }
    });
  });

  group("Test REPL functions with self keys", () {
    final bool enforceNamespace = true;
    test("Test Put", () async {
      List<String> args = ["put", "demotest.$namespace$atSign", "initial"];
      String result = await repl.put(args, enforceNamespace);
      expect(result.isNotEmpty, true);
    });
    test("Test Get from another atsign", () async {
      List<String> args = ["get", "demotest.$namespace$atSign"];
      String result = await repl.getKey(args);
      expect(result, " => initial");
    });
    test("Test Update from another atsign", () async {
      List<String> args = ["put", "demotest.$namespace$atSign", "updated"];
      String result = await repl.put(args, enforceNamespace);
      expect(result.isNotEmpty, true);
    });
    test("Test Get after update", () async {
      List<String> args = ["get", "demotest.$namespace$atSign"];
      String result = await repl.getKey(args);
      expect(result, " => updated");
    });

    test("Test Delete", () async {
      List<String> args = ["delete", "demotest.$namespace@chess69lovely"];
      String result = await repl.delete(args);
      expect(result, " => true");
    });
  });
}

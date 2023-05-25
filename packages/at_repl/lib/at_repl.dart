import 'package:at_client/at_client.dart';
import 'package:at_commons/at_builders.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:at_onboarding_cli/at_onboarding_cli.dart';
import 'package:at_repl/home_directory.dart';

class REPL {
  final String atSign;
  late AtOnboardingService _atOnboardingService;

  REPL(this.atSign);

  AtClient get atClient => _atOnboardingService.atClient!;

  Future<bool> authenticate() {
    AtOnboardingPreference pref = AtOnboardingPreference()
      ..isLocalStoreRequired = true
      ..hiveStoragePath = '${getHomeDirectory()}/.atsign/temp/hive'
      ..commitLogPath = '${getHomeDirectory()}/.atsign/temp/commitlog'
      ..downloadPath = '${getHomeDirectory()}/.atsign/temp/download'
      ..namespace = 'soccer0'
      ..atKeysFilePath = "${getHomeDirectory()}/.atsign/keys/${atSign}_key.atKeys";

    _atOnboardingService = AtOnboardingServiceImpl(atSign, pref);

    return _atOnboardingService.authenticate();
  }

  Future<String> executeCommand(String command) async {
    late String result;
    if (_atOnboardingService == null) {
      throw Exception('Not authenticated. Call `authenticate()` first.');
    }
    if (_atOnboardingService.atClient == null) {
      throw Exception('AtClient is null for some reason...');
    }
    if (_atOnboardingService.atClient!.getRemoteSecondary() == null) {
      throw Exception('RemoteSecondary is null for some reason...');
    }
    final AtClient atClient = _atOnboardingService.atClient!;
    for (var atKey in (await atClient.getAtKeys())) {
      // print(atKey);
    }
    final RemoteSecondary rs = _atOnboardingService.atClient!.getRemoteSecondary()!;

    final String? response = (await rs.executeCommand(command, auth: true));

    if (response == null) {
      throw Exception('Result is null for some reason after executing command: $command');
    }

    result = response;

    return result;
  }

  Future<String> getKey(List<String> args, bool enforceNamespace) async {
    if (args.length != 2) throw Exception("Please enter an atKey -> /get test@alice");
    String key = args[1];
    KeyType type = AtKey.getKeyType(key);
    String? name;
    String atSign = key.substring(key.indexOf('@'));
    String namespace = '';
    if (enforceNamespace) {
      name = key.substring(0, key.indexOf('.'));
      namespace = key.substring(key.indexOf('.') + 1, key.indexOf('@'));
    } else {
      name = key.substring(0, key.indexOf('@'));
    }
    switch (type) {
      case KeyType.selfKey:
        AtKey selfKey = AtKey.self(name, namespace: namespace, sharedBy: atSign).build();
        AtValue atValue = await atClient.get(selfKey);
        return " => ${atValue.value}";
      case KeyType.sharedKey:
        AtKey sharedKey = AtKey.shared(name, namespace: namespace, sharedBy: atSign).build();
        AtValue atValue = await atClient.get(sharedKey);
        return " => ${atValue.value}";
      case KeyType.publicKey:
        AtKey publicKey = AtKey.public(name, namespace: namespace, sharedBy: atSign).build();
        AtValue atValue = await atClient.get(publicKey);
        return " => ${atValue.value}";
      case KeyType.privateKey:
        AtKey privateKey = AtKey.private(name, namespace: namespace).build();
        AtValue atValue = await atClient.get(privateKey);
        return " => ${atValue.value}";
      case KeyType.invalidKey:
        return " => Keyname is typed incorrectly";
      default:
        return " => i don't do funny key types ($type)";
    }
  }

  Future<String> put(List<String> args, bool enforceNamespace) async {
    if (args.length != 3) throw Exception("Please enter an atKey and a value -> /put test@alice value");
    String key = args[1];
    String value = args[2];
    KeyType type = AtKey.getKeyType(key);
    String? name;
    String atSign = key.substring(key.indexOf('@'));
    String namespace = '';
    if (enforceNamespace) {
      name = key.substring(0, key.indexOf('.'));
      namespace = key.substring(key.indexOf('.') + 1, key.indexOf('@'));
    } else {
      name = key.substring(0, key.indexOf('@'));
    }
    switch (type) {
      case KeyType.selfKey:
        AtKey selfKey = AtKey.self(name, namespace: namespace, sharedBy: atSign).build();
        bool data = await atClient.put(selfKey, value);
        return " key creation result - $data";
      case KeyType.sharedKey:
        AtKey sharedKey = AtKey.shared(name, namespace: namespace, sharedBy: atSign).build();
        bool data = await atClient.put(sharedKey, value);
        return " key creation result - $data";
      case KeyType.publicKey:
        AtKey publicKey = AtKey.public(name, namespace: namespace, sharedBy: atSign).build();
        bool data = await atClient.put(publicKey, value);
        return " key creation result - $data";
      case KeyType.privateKey:
        AtKey privateKey = AtKey.private(name, namespace: namespace).build();
        bool data = await atClient.put(privateKey, value);
        return " => key creation result - $data";
      case KeyType.invalidKey:
        return " => make it properly please";
      default:
        return " => i don't do funny key types ($type)";
    }
  }

  Future<String> delete(List<String> args, bool enforceNamespace) async {
    if (args.length != 2) throw Exception("Please enter an atKey -> /delete test@alice");
    String key = args[1];
    KeyType type = AtKey.getKeyType(key);
    String? name;
    String atSign = key.substring(key.indexOf('@'));
    String namespace = '';
    if (enforceNamespace) {
      name = key.substring(0, key.indexOf('.'));
      namespace = key.substring(key.indexOf('.') + 1, key.indexOf('@'));
    } else {
      name = key.substring(0, key.indexOf('@'));
    }
    switch (type) {
      case KeyType.selfKey:
        AtKey selfKey = AtKey.self(name, namespace: namespace, sharedBy: atSign).build();
        bool response = await atClient.delete(selfKey);
        return (" => $response");
      case KeyType.sharedKey:
        AtKey sharedKey = AtKey.shared(name, namespace: namespace, sharedBy: atSign).build();
        bool response = await atClient.delete(sharedKey);
        return (" => $response");
      case KeyType.publicKey:
        AtKey publicKey = AtKey.public(name, namespace: namespace, sharedBy: atSign).build();
        bool response = await atClient.delete(publicKey);
        return (" => $response");
      case KeyType.privateKey:
        AtKey privateKey = AtKey.private(name, namespace: namespace).build();
        bool response = await atClient.delete(privateKey);
        return (" => $response");
      case KeyType.invalidKey:
        return (" => Keyname is typed incorrectly");
      default:
        return (" => i don't do funny key types ($type)");
    }
  }
}

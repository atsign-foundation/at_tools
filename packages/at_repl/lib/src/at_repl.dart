import 'package:at_client/at_client.dart';
import 'package:at_onboarding_cli/at_onboarding_cli.dart';
import 'package:at_repl/src/home_directory.dart';

import 'repl_listener.dart';

class REPL {
  ///User's atSign
  final String atSign;
  final String namespace = 'impressed1';

  ///defaults to root.atsign.org:64 which is the atDirectory
  final String rootUrl;

  ///is null until the REPL has authenticated
  late AtOnboardingService _atOnboardingService;
  REPL(this.atSign, {this.rootUrl = 'root.atsign.org:64'});

  AtClient get atClient => AtClientManager.getInstance().atClient;

  ///authenticates onboardingService
  Future<bool> authenticate() {
    AtOnboardingPreference pref = AtOnboardingPreference()
      ..isLocalStoreRequired = true
      ..hiveStoragePath = '${getHomeDirectory()}/.atsign/temp/hive'
      ..commitLogPath = '${getHomeDirectory()}/.atsign/temp/commitlog'
      ..downloadPath = '${getHomeDirectory()}/.atsign/temp/download'
      ..namespace = 'impressed1'
      ..syncIntervalMins = 1
      ..rootDomain = rootUrl.split(':')[0]
      ..rootPort = int.parse(rootUrl.split(':')[1])
      ..atKeysFilePath = "${getHomeDirectory()}/.atsign/keys/${atSign}_key.atKeys";

    _atOnboardingService = AtOnboardingServiceImpl(atSign, pref);
    return _atOnboardingService.authenticate();
  }

  /// executes protocol verbs
  Future<String> executeCommand(String command) async {
    late String result;
    if (_atOnboardingService.atClient == null) {
      throw Exception('AtClient is null for some reason...');
    }
    if (_atOnboardingService.atClient!.getRemoteSecondary() == null) {
      throw Exception('RemoteSecondary is null for some reason...');
    }
    final RemoteSecondary rs = atClient.getRemoteSecondary()!;

    final String? response = (await rs.executeCommand(command, auth: true));

    if (response == null) {
      throw Exception('Result is null for some reason after executing command: $command');
    }

    result = response;

    return result;
  }

  ///gets the value of desired key
  Future<String> getKey(List<String> args, bool enforceNamespace) async {
    if (args.length != 2) {
      throw Exception("Please enter a record ID - e.g. /get test@alice");
    }
    if (!enforceNamespace) {
      if (args[1].contains('.')) {
        args[1] = "${args[1].substring(0, args[1].indexOf('@'))}${args[1].substring(args[1].indexOf('@'))}";
      }
    }
    String id = args[1];

    AtValue atValue = await atClient.get(AtKey.fromString(id));
    return " => ${atValue.value}";
  }

  ///puts the atKey to secondary server
  Future<String> put(List<String> args, bool enforceNamespace) async {
    if (args.length != 3) {
      throw Exception("Please enter a record ID and a value - e.g. /put test@alice value");
    }
    if (!enforceNamespace) {
      if (args[1].contains('.')) {
        args[1] = "${args[1].substring(0, args[1].indexOf('@'))}${args[1].substring(args[1].indexOf('@'))}";
      }
    }
    String id = args[1];
    String value = args[2];

    dynamic result = await atClient.put(AtKey.fromString(id), value);
    return " key creation result - $result";
  }

  ///deletes atKey from secondary server
  Future<String> delete(List<String> args, bool enforceNamespace) async {
    if (args.length != 2) {
      throw Exception("Please enter a record ID - e.g. /delete test@alice");
    }
    if (!enforceNamespace) {
      if (args[1].contains('.')) {
        args[1] = "${args[1].substring(0, args[1].indexOf('@'))}${args[1].substring(args[1].indexOf('@'))}";
      }
    }
    String id = args[1];
    dynamic response = await atClient.delete(AtKey.fromString(id));
    return (" => $response");
  }

  ///syncs local secondary with remote secondary
  Future<void> syncSecondary() async {
    REPLListener replListener = REPLListener();
    atClient.syncService.addProgressListener(replListener);
    while (!replListener.syncComplete) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    return;
  }
}

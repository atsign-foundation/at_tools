import 'package:at_client/at_client.dart';
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
}

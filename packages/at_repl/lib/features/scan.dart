import 'package:at_client/at_client.dart';

Future<List<AtKey>> getAtKeys(AtClient atClient, {String? regex}) async {
  return await atClient.getAtKeys(regex: regex);
}

// TODO : write function called handleScan which handles the `/scan` command
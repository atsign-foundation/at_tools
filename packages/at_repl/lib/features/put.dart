import 'package:at_client/at_client.dart';

Future<bool> put(AtClient atClient, {required String atKeyStr, required String value}) async {
  return atClient.put(AtKey.fromString(atKeyStr), value,
      putRequestOptions: PutRequestOptions()..useRemoteAtServer = true);
}

// TODO : write function called handlePut which handles the `/put` command
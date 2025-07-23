import 'package:at_client/at_client.dart';

Future<String?> get(AtClient atClient, {required String atKeyStr}) async {
  AtKey atKey = AtKey.fromString(atKeyStr);
  AtValue? atValue = await atClient.get(atKey,
      getRequestOptions: GetRequestOptions()..useRemoteAtServer = true);
  return atValue.value;
}

// TODO: write function called handleGet which handles the `/get` command
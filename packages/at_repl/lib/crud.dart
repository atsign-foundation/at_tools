import 'package:at_client/at_client.dart';

Future<List<AtKey>> _getAtKeys(AtClient atClient, {String? regex}) async {
  return await atClient.getAtKeys(regex: regex);
}

Future<bool> _put(AtClient atClient, {required String atKeyStr, required String value}) async {
  return atClient.put(AtKey.fromString(atKeyStr), value,
      putRequestOptions: PutRequestOptions()..useRemoteAtServer = true);
}

Future<String?> _get(AtClient atClient, {required String atKeyStr}) async {
  AtKey atKey = AtKey.fromString(atKeyStr);
  AtValue? atValue = await atClient.get(atKey,
      getRequestOptions: GetRequestOptions()..useRemoteAtServer = true);
  return atValue.value;
}

Future<bool> _delete(AtClient atClient, {required String atKeyStr}) async {
  AtKey atKey = AtKey.fromString(atKeyStr);
  return await atClient.delete(atKey,
      deleteRequestOptions: DeleteRequestOptions()..useRemoteAtServer = true);
}

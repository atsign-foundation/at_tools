import 'package:at_client/at_client.dart';

Future<bool> delete(AtClient atClient, {required String atKeyStr}) async {
  AtKey atKey = AtKey.fromString(atKeyStr);
  return await atClient.delete(atKey,
      deleteRequestOptions: DeleteRequestOptions()..useRemoteAtServer = true);
}

// TODO: write function called handleDelete which handles the `/delete` command
import 'package:at_client/at_client.dart';

class REPLListener implements SyncProgressListener {
  bool syncComplete = false;
  String syncResult = '';

  @override
  void onSyncProgressEvent(SyncProgress syncProgress) {
    if (syncProgress.localCommitIdBeforeSync! < syncProgress.serverCommitId!) {
      print("Local is behind Remote, syncing to cloud.");
    } else if (syncProgress.localCommitIdBeforeSync! >
        syncProgress.serverCommitId!) {
      print("Remote is behind Local, syncing locally.");
    }

    if (syncProgress.syncStatus == SyncStatus.failure ||
        syncProgress.syncStatus == SyncStatus.success) {
      syncComplete = true;
    }
    if (syncProgress.syncStatus == SyncStatus.failure) {
      syncResult = 'Failed';
    }
    if (syncProgress.syncStatus == SyncStatus.success) {
      syncResult = 'Succeeded';
    }

    return;
  }
}

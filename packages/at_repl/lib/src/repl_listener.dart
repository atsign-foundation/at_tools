import 'package:at_client/at_client.dart';
import 'package:at_utils/at_logger.dart';

class REPLListener implements SyncProgressListener {
  bool syncComplete = false;
  String syncResult = '';
  final AtSignLogger _logger = AtSignLogger("repl");

  @override
  void onSyncProgressEvent(SyncProgress syncProgress) {
    if (syncProgress.localCommitIdBeforeSync! < syncProgress.serverCommitId!) {
      _logger.info("Local is behind Remote, syncing to cloud.");
    } else if (syncProgress.localCommitIdBeforeSync! >
        syncProgress.serverCommitId!) {
      _logger.info("Remote is behind Local, syncing locally.");
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

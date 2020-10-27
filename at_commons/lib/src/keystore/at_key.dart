import 'package:at_commons/at_commons.dart';

class AtKey {
  String key;
  String sharedWith;
  String sharedBy;
  String namespace;
  Metadata metadata;
  bool isRef = false;

  @override
  String toString() {
    return 'AtKey{key: $key, sharedWith: $sharedWith, sharedBy: $sharedBy, namespace: $namespace, metadata: $metadata, isRef: $isRef}';
  }

  static AtKey fromString(String key) {
    var atKey = AtKey();
    var metaData = Metadata();
    if (key.startsWith(AT_PKAM_PRIVATE_KEY) ||
        key.startsWith(AT_PKAM_PUBLIC_KEY)) {
      atKey.key = key;
      atKey.metadata = metaData;
      return atKey;
    } else if (key.startsWith(AT_ENCRYPTION_PRIVATE_KEY)) {
      atKey.key = key.split('@')[0];
      atKey.sharedBy = key.split('@')[1];
      atKey.metadata = metaData;
      return atKey;
    }
    var keyParts = key.split(':');
    if (keyParts.length == 1) {
      atKey.sharedBy = keyParts[0].split('@')[1];
      atKey.key = keyParts[0].split('@')[0];
    } else {
      if (keyParts[0] == 'public') {
        metaData.isPublic = true;
      } else if (keyParts[0] == CACHED) {
        metaData.isCached = true;
        atKey.sharedWith = keyParts[1];
      } else {
        atKey.sharedWith = keyParts[0];
      }
      var keyArr;
      if (keyParts[0] == CACHED) {
        keyArr = keyParts[2].split('@');
      } else {
        keyArr = keyParts[1].split('@');
      }
      if (keyArr != null && keyArr.length == 2) {
        atKey.sharedBy = keyArr[1];
        atKey.key = keyArr[0];
      } else {
        atKey.key = keyArr[0];
      }
    }
    //remove namespace
    if (atKey.key != null && atKey.key.contains('.')) {
      var namespaceIndex = atKey.key.lastIndexOf('.');
      if (namespaceIndex > -1) {
        atKey.namespace = atKey.key.substring(namespaceIndex + 1);
        atKey.key = atKey.key.substring(0, namespaceIndex);
      }
    } else {
      metaData.namespaceAware = false;
    }
    atKey.metadata = metaData;
    return atKey;
  }
}

class Metadata {
  int ttl;
  int ttb;
  int ttr;
  bool ccd;
  DateTime availableAt;
  DateTime expiresAt;
  DateTime refreshAt;
  bool isPublic = false;
  bool isHidden = false;
  bool namespaceAware = true;
  bool isBinary = false;
  bool isEncrypted = false;
  bool isCached = false;

  @override
  String toString() {
    return 'Metadata{ttl: $ttl, ttb: $ttb, ttr: $ttr,ccd: $ccd, isPublic: $isPublic, isHidden: $isHidden, availableAt : ${availableAt?.toUtc().toString()}, expiresAt : ${expiresAt?.toUtc().toString()}, refreshAt : ${refreshAt?.toUtc().toString()}, isBinary : ${isBinary}, isEncrypted : ${isEncrypted}, isCached : ${isCached}';
  }
}

class AtValue {
  dynamic value;
  Metadata metadata;

  @override
  String toString() {
    return 'AtValue{value: $value, metadata: $metadata}';
  }
}

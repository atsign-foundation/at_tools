import 'package:at_commons/at_commons.dart';

class AtKey {
  String? key;
  String? sharedWith;
  String? sharedBy;
  String? namespace;
  Metadata? metadata;
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
    if (atKey.key != null && atKey.key!.contains('.')) {
      var namespaceIndex = atKey.key!.lastIndexOf('.');
      if (namespaceIndex > -1) {
        atKey.namespace = atKey.key!.substring(namespaceIndex + 1);
        atKey.key = atKey.key!.substring(0, namespaceIndex);
      }
    } else {
      metaData.namespaceAware = false;
    }
    atKey.metadata = metaData;
    return atKey;
  }
}

class Metadata {
  int? ttl;
  int? ttb;
  int? ttr;
  bool? ccd;
  DateTime? availableAt;
  DateTime? expiresAt;
  DateTime? refreshAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? dataSignature;
  bool? isPublic = false;
  bool isHidden = false;
  bool namespaceAware = true;
  bool? isBinary = false;
  bool? isEncrypted;
  bool isCached = false;

  @override
  String toString() {
    return 'Metadata{ttl: $ttl, ttb: $ttb, ttr: $ttr,ccd: $ccd, isPublic: $isPublic, isHidden: $isHidden, availableAt : ${availableAt?.toUtc().toString()}, expiresAt : ${expiresAt?.toUtc().toString()}, refreshAt : ${refreshAt?.toUtc().toString()}, createdAt : ${createdAt?.toUtc().toString()},updatedAt : ${updatedAt?.toUtc().toString()},isBinary : ${isBinary}, isEncrypted : ${isEncrypted}, isCached : ${isCached}, dataSignature: ${dataSignature}}';
  }

  Map toJson() {
    var map = {};
    map['availableAt'] = availableAt?.toUtc().toString();
    map['expiresAt'] = expiresAt?.toUtc().toString();
    map['refreshAt'] = refreshAt?.toUtc().toString();
    map[CREATED_AT] = createdAt?.toUtc().toString();
    map[UPDATED_AT] = updatedAt?.toUtc().toString();
    map['isPublic'] = isPublic;
    map[AT_TTL] = ttl;
    map[AT_TTB] = ttb;
    map[AT_TTR] = ttr;
    map[CCD] = ccd;
    map[IS_BINARY] = isBinary;
    map[IS_ENCRYPTED] = isEncrypted;
    map[PUBLIC_DATA_SIGNATURE] = dataSignature;
    return map;
  }

  static Metadata fromJson(Map json) {
    var metaData = Metadata();
    try {
      metaData.expiresAt =
          (json['expiresAt'] == null || json['expiresAt'] == 'null')
              ? null
              : DateTime.parse(json['expiresAt']);
      metaData.refreshAt =
          (json['refreshAt'] == null || json['refreshAt'] == 'null')
              ? null
              : DateTime.parse(json['refreshAt']);
      metaData.availableAt =
          (json['availableAt'] == null || json['availableAt'] == 'null')
              ? null
              : DateTime.parse(json['availableAt']);
      metaData.createdAt =
          (json[CREATED_AT] == null || json[CREATED_AT] == 'null')
              ? null
              : DateTime.parse(json[CREATED_AT]);
      metaData.updatedAt =
          (json[UPDATED_AT] == null || json[UPDATED_AT] == 'null')
              ? null
              : DateTime.parse(json[UPDATED_AT]);
      metaData.ttl = (json[AT_TTL] is String)
          ? int.parse(json[AT_TTL])
          : (json[AT_TTL] == null)
              ? 0
              : json[AT_TTL];
      metaData.ttb = (json[AT_TTB] is String)
          ? int.parse(json[AT_TTB])
          : (json[AT_TTB] == null)
              ? 0
              : json[AT_TTB];
      metaData.ttr = (json[AT_TTR] is String)
          ? int.parse(json[AT_TTR])
          : (json[AT_TTR] == null)
              ? 0
              : json[AT_TTR];
      metaData.ccd = json[CCD];
      metaData.isBinary = json[IS_BINARY];
      metaData.isEncrypted = json[IS_ENCRYPTED];
      metaData.isPublic = json[IS_PUBLIC];
      metaData.dataSignature = json[PUBLIC_DATA_SIGNATURE];
    } catch (error) {
      print('AtMetaData.fromJson error: ' + error.toString());
    }
    return metaData;
  }
}

class AtValue {
  dynamic value;
  Metadata? metadata;

  @override
  String toString() {
    return 'AtValue{value: $value, metadata: $metadata}';
  }
}

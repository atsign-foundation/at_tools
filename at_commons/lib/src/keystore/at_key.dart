import 'package:at_commons/at_commons.dart';
import 'package:at_commons/src/keystore/at_key_builder_impl.dart';

class AtKey {
  String? key;
  String? sharedWith;
  String? sharedBy;
  String? namespace;
  Metadata? metadata;
  bool isRef = false;

  @override
  String toString() {
    // If metadata.isPublic is true and metadata.isCached is true,
    // return cached public key
    if (key!.startsWith('cached:public:') ||
        (metadata != null &&
            (metadata!.isPublic != null && metadata!.isPublic!) &&
            (metadata!.isCached))) {
      return 'cached:public:$key.$namespace$sharedBy';
    }
    // If metadata.isPublic is true, return public key
    if (key!.startsWith('public:') ||
        (metadata != null &&
            metadata!.isPublic != null &&
            metadata!.isPublic!)) {
      return 'public:$key.$namespace$sharedBy';
    }
    //If metadata.isCached is true, return shared cached key
    if (key!.startsWith('cached:') ||
        (metadata != null && metadata!.isCached)) {
      return 'cached:$sharedWith:$key.$namespace$sharedBy';
    }
    // If key starts with privatekey:, return private key
    if (key!.startsWith('privatekey:')) {
      return '$key';
    }
    //If sharedWith is not null, return sharedKey
    if (sharedWith != null && sharedWith!.isNotEmpty) {
      return '$sharedWith:$key.$namespace$sharedBy';
    }
    // Defaults to return a self key.
    return '$key.$namespace$sharedBy';
  }

  /// Public keys are visible to everyone and shown in an authenticated/unauthenticated scan
  ///
  /// Builds a public key and returns a [PublicKeyBuilder]
  ///
  ///Example: public:phone.wavi@alice.
  ///```dart
  ///AtKey publicKey = AtKey.public('phone', namespace: 'wavi', sharedBy: '@alice').build();
  ///```
  static PublicKeyBuilder public(String key,
      {String? namespace, String sharedBy = ''}) {
    return PublicKeyBuilder()
      ..key(key)
      ..namespace(namespace)
      ..sharedBy(sharedBy);
  }

  /// Shared Keys are shared with other atSign. The owner can see the keys on
  /// authenticated scan. The SharedWith atSign can lookup the value of the key.
  ///
  ///Builds a sharedWith key and returns a [SharedKeyBuilder]. Optionally the key
  ///can be cached on the [AtKey.sharedWith] atSign.
  ///
  ///Example: @bob:phone.wavi@alice.
  ///```dart
  ///AtKey sharedKey = (AtKey.shared('phone', 'wavi')
  ///     ..sharedWith('@bob')).build();
  ///```
  /// To cache a key on the @bob atSign.
  /// ```dart
  ///AtKey atKey = (AtKey.shared('phone', namespace: 'wavi', sharedBy: '@alice')
  ///  ..sharedWith('bob')
  ///  ..cache(1000, true))
  ///  .build();
  /// ```
  static SharedKeyBuilder shared(String key,
      {String? namespace, String sharedBy = ''}) {
    return SharedKeyBuilder()
      ..key(key)
      ..namespace(namespace)
      ..sharedBy(sharedBy);
  }

  /// Self keys that are created by the owner of the atSign and the keys can be
  /// accessed by the owner of the atSign only.
  ///
  /// Builds a self key and returns a [SelfKeyBuilder].
  ///
  ///
  /// Example: phone.wavi@alice
  /// ```dart
  /// AtKey selfKey = AtKey.self('phone', namespace: 'wavi', sharedBy: '@alice').build();
  /// ```
  static SelfKeyBuilder self(String key,
      {String? namespace, String sharedBy = ''}) {
    return SelfKeyBuilder()
      ..key(key)
      ..namespace(namespace)
      ..sharedBy(sharedBy);
  }

  /// Private key's that are created by the owner of the atSign and these keys
  /// are not shown in the scan.
  ///
  /// Builds a private key and returns a [PrivateKeyBuilder]. Private key's are not
  /// returned when fetched for key's of atSign.
  ///
  /// Example: privatekey:phone.wavi@alice
  /// ```dart
  /// AtKey privateKey = AtKey.private('phone', namespace: 'wavi').build();
  /// ```
  static PrivateKeyBuilder private(String key, {String? namespace}) {
    return PrivateKeyBuilder()
      ..key(key)
      ..namespace(namespace);
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
    //If key does not contain '@'. or key has space, it is not a valid key.
    if (!key.contains('@') || key.contains(' ')) {
      throw InvalidSyntaxException('$key is not well-formed key');
    }
    var keyParts = key.split(':');
    // If key does not contain ':' Ex: phone@bob; then keyParts length is 1
    // where phone is key and @bob is sharedBy
    if (keyParts.length == 1) {
      atKey.sharedBy = keyParts[0].split('@')[1];
      atKey.key = keyParts[0].split('@')[0];
    } else {
      // Example key: public:phone@bob
      if (keyParts[0] == 'public') {
        metaData.isPublic = true;
      }
      // Example key: cached:@alice:phone@bob
      else if (keyParts[0] == CACHED) {
        metaData.isCached = true;
        atKey.sharedWith = keyParts[1];
      } else {
        atKey.sharedWith = keyParts[0];
      }
      List<String> keyArr = [];
      if (keyParts[0] == CACHED) {
        keyArr = keyParts[2].split('@');
      } else {
        keyArr = keyParts[1].split('@');
      }
      if (keyArr.length == 2) {
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

/// Represents a public key.
class PublicKey extends AtKey {
  PublicKey() {
    super.metadata = Metadata();
    super.metadata!.isPublic = true;
  }

  @override
  String toString() {
    return 'public:$key.$namespace$sharedBy';
  }
}

///Represents a Self key.
class SelfKey extends AtKey {
  SelfKey() {
    super.metadata = Metadata();
    super.metadata?.isPublic = false;
  }

  @override
  String toString() {
    // If sharedWith is populated and sharedWith is equal to sharedBy, then
    // keys is a self key.
    // @alice:phone@alice or phone@alice
    if (sharedWith != null && sharedWith!.isNotEmpty) {
      return '$sharedWith:$key.$namespace$sharedBy';
    }
    return '$key.$namespace$sharedBy';
  }
}

/// Represents a key shared to another atSign.
class SharedKey extends AtKey {
  SharedKey() {
    super.metadata = Metadata();
  }

  @override
  String toString() {
    return '$sharedWith:$key.$namespace$sharedBy';
  }
}

/// Represents a Private key.
class PrivateKey extends AtKey {
  PrivateKey() {
    super.metadata = Metadata();
  }

  @override
  String toString() {
    return 'privatekey:$key';
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
  String? sharedKeyStatus;
  bool? isPublic = false;
  bool isHidden = false;
  bool namespaceAware = true;
  bool? isBinary = false;
  bool? isEncrypted;
  bool isCached = false;
  String? sharedKeyEnc;
  String? pubKeyCS;

  @override
  String toString() {
    return 'Metadata{ttl: $ttl, ttb: $ttb, ttr: $ttr,ccd: $ccd, isPublic: $isPublic, isHidden: $isHidden, availableAt : ${availableAt?.toUtc().toString()}, expiresAt : ${expiresAt?.toUtc().toString()}, refreshAt : ${refreshAt?.toUtc().toString()}, createdAt : ${createdAt?.toUtc().toString()},updatedAt : ${updatedAt?.toUtc().toString()},isBinary : $isBinary, isEncrypted : $isEncrypted, isCached : $isCached, dataSignature: $dataSignature, sharedKeyStatus: $sharedKeyStatus, encryptedSharedKey: $sharedKeyEnc, pubKeyCheckSum: $pubKeyCS}';
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
    map[SHARED_KEY_STATUS] = sharedKeyStatus;
    map[SHARED_KEY_ENCRYPTED] = sharedKeyEnc;
    map[SHARED_WITH_PUBLIC_KEY_CHECK_SUM] = pubKeyCS;
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
      metaData.sharedKeyStatus = json[SHARED_KEY_STATUS];
      metaData.sharedKeyEnc = json[SHARED_KEY_ENCRYPTED];
      metaData.pubKeyCS = json[SHARED_WITH_PUBLIC_KEY_CHECK_SUM];
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

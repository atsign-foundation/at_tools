import 'package:at_commons/at_commons.dart';
import 'package:at_commons/src/keystore/at_key_builder_impl.dart';

class AtKey {
  late String key;
  String? sharedWith;
  String? sharedBy;
  late String namespace;
  Metadata? metadata;
  bool isRef = false;

  @override
  String toString() {
    return 'AtKey{key: $key, sharedWith: $sharedWith, sharedBy: $sharedBy, namespace: $namespace, metadata: $metadata, isRef: $isRef}';
  }

  ///Builds a public key and returns a [PublicKeyBuilder]
  ///
  ///Example: public:phone.wavi@alice.
  ///```dart
  ///AtKey publicKey = AtKey.public('phone', 'wavi').build();
  ///```
  static PublicKeyBuilder public(String key, String namespace,
      {ValueType valueType = ValueType.text}) {
    return PublicKeyBuilder(valueType)
      ..key(key)
      ..namespace(namespace);
  }

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
  ///AtKey atKey = (AtKey.shared('phone', 'wavi')
  ///  ..sharedWith('bob')
  ///  ..cache(1000, true))
  ///    .build();
  /// ```
  static SharedKeyBuilder shared(String key, String namespace,
      {ValueType valueType = ValueType.text}) {
    return SharedKeyBuilder(valueType)
      ..key(key)
      ..namespace(namespace);
  }

  /// Builds a self key and returns a [SelfKeyBuilder].
  ///
  /// Example: phone.wavi@alice
  /// ```dart
  /// AtKey selfKey = AtKey.self('phone', 'wavi').build();
  /// ```
  static SelfKeyBuilder self(String key, String namespace,
      {ValueType valueType = ValueType.text}) {
    return SelfKeyBuilder(valueType)
      ..key(key)
      ..namespace(namespace);
  }

  /// Builds a hidden key and returns a [HiddenKeyBuilder].
  ///
  /// Example: _phone.wavi@alice
  /// ```dart
  /// AtKey selfKey = AtKey.hidden('phone', 'wavi').build();
  /// ```
  static HiddenKeyBuilder hidden(String key, String namespace,
      {ValueType valueType = ValueType.text}) {
    return HiddenKeyBuilder(valueType)
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

/// Represents a public key.
class PublicKey extends AtKey {
  PublicKey() {
    super.metadata ??= Metadata();
    super.metadata!.isPublic = true;
  }
}

///Represents a Self key.
class SelfKey extends AtKey {
  SelfKey() {
    super.metadata ??= Metadata();
    super.metadata!.isPublic = false;
  }
}

/// Represents a key shared to another atSign.
class SharedKey extends AtKey {
  SharedKey() {
    super.metadata ??= Metadata();
  }
}

/// Represents a Hidden key.
class HiddenKey extends AtKey {
  HiddenKey() {
    super.metadata ??= Metadata();
    super.metadata!.isHidden = true;
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

  @override
  String toString() {
    return 'Metadata{ttl: $ttl, ttb: $ttb, ttr: $ttr,ccd: $ccd, isPublic: $isPublic, isHidden: $isHidden, availableAt : ${availableAt?.toUtc().toString()}, expiresAt : ${expiresAt?.toUtc().toString()}, refreshAt : ${refreshAt?.toUtc().toString()}, createdAt : ${createdAt?.toUtc().toString()},updatedAt : ${updatedAt?.toUtc().toString()},isBinary : $isBinary, isEncrypted : $isEncrypted, isCached : $isCached, dataSignature: $dataSignature, sharedKeyStatus: $sharedKeyStatus}';
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

/// Enumeration that represents value type in @protocol
///
/// binary - Represents binary data like images
/// text   - Anything that's not binary falls into this category
enum ValueType { binary, text }

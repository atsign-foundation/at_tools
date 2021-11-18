import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:at_persistence_secondary_server/at_persistence_secondary_server.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';

class HiveDoctor {
  late final _storagePath;

  void init(String storagePath) {
    Hive.init(storagePath);
    _storagePath = storagePath;
    if (!Hive.isAdapterRegistered(AtDataAdapter().typeId)) {
      Hive.registerAdapter(AtDataAdapter());
    }
    if (!Hive.isAdapterRegistered(AtMetaDataAdapter().typeId)) {
      Hive.registerAdapter(AtMetaDataAdapter());
    }
    if (!Hive.isAdapterRegistered(CommitEntryAdapter().typeId)) {
      Hive.registerAdapter(CommitEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(CommitOpAdapter().typeId)) {
      Hive.registerAdapter(CommitOpAdapter());
    }
  }

  Future<bool> recoverBox(String atSign) async {
    var boxName = _getShaForAtSign(atSign);
    final secretString = File('$_storagePath/$boxName.hash').readAsStringSync();
    final secret = Uint8List.fromList(secretString.codeUnits);
    final box =
        await Hive.openBox('$boxName', encryptionCipher: HiveAesCipher(secret));
    return box.isOpen;
  }

  static String _getShaForAtSign(String atsign) {
    // encode the given atsign
    var bytes = utf8.encode(atsign);
    return sha256.convert(bytes).toString();
  }
}

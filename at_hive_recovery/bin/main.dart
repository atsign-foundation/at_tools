import 'dart:io';

import 'package:at_hive_recovery/src/hive_doctor.dart';

void main(var args) async {
  if (args == null || args.length < 2) {
    print('usage: dart bin/main dart <atsign> <dir_path_of_hive_box>');
    exit(0);
  }
  final atSign = args[0];
  final hiveStorageDir = args[1];
  final hiveDoctor = HiveDoctor();
  hiveDoctor.init(hiveStorageDir);
  final recoveryResult = await hiveDoctor.recoverBox(atSign);
  print('hive recovery result: $recoveryResult');
  if (recoveryResult) {
    print('hive box successfully recovered');
  } else {
    print('unable to recover hive box');
  }
}

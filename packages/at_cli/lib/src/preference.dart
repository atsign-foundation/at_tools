class AtCliPreference {
  String rootDomain = 'root.atsign.org';
  int rootPort = 64;
  bool authRequired = false;
  late String authMode;
  late String authKeyFile;
  String namespace = '';
  bool cache = false;
  String? cacheDir;
}

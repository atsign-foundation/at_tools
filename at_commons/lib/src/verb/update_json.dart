import 'package:at_commons/at_commons.dart';

class UpdateParams {
  String atKey;
  dynamic value;
  String sharedBy;
  String sharedWith;
  Metadata metadata;

  Map toJson() {
    Map map = {};
    map['atKey'] = atKey;
    map['value'] = value;
    map['metadata'] = metadata;
    return map;
  }

  static UpdateParams fromJson(Map dataMap) {
    var updateParams = UpdateParams();
    updateParams.atKey = dataMap[AT_KEY];
    updateParams.value = dataMap[AT_VALUE];
    updateParams.sharedBy = dataMap['sharedBy'];
    updateParams.sharedWith = dataMap['sharedWith'];
    updateParams.metadata = Metadata.fromJson(dataMap['metadata']);
    return updateParams;
  }
}

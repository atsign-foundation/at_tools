import 'package:at_commons/at_commons.dart';

void main(List<String> arguments) {
  //verb syntax
  print(VerbSyntax.from);
  //use constant from at_constants
  print(AT_SIGN);
  // Use At StringBuffer
  try {
    var buffer = StringBuffer(capacity: 1000);
    buffer.append('test_data');
  } on BufferOverFlowException {
    print('At Buffer OverFlow Exception');
  }
  // create AtKey
  var atKey = AtKey();
  atKey.key = 'test_key';
  atKey.sharedWith = '@alice';
  var metadata = Metadata();
  metadata.isPublic = false;
  metadata.ttl = 20000;
  metadata.namespaceAware = false;
  atKey.metadata = metadata;
  // user builders for example UpdateVerbBuilder
  var updateBuilder = UpdateVerbBuilder();
  updateBuilder.atKey = 'test_key';
  updateBuilder.value = 'test_value';
  var update_command = updateBuilder.buildCommand();
  print(update_command);
}

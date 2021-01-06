import 'dart:io';

import 'package:at_server_status/at_server_status.dart';

void main() async {
  var atSigns = [
    '@alice🛠',
    '@ashish🛠',
    '@barbara🛠',
    '@bob🛠',
    '@colin🛠',
    '@egbiometric🛠',
    '@egcovidlab🛠',
    '@egcreditbureau🛠',
    '@eggovagency🛠',
    '@emoji🦄🛠',
    '@eve🛠',
    '@jagan🛠',
    '@kevin🛠',
    '@murali🛠',
    '@naresh🛠',
    '@purnima🛠',
    '@sameeraja🛠',
    '@sitaram🛠'
  ];

  Future<AtStatus> getAtStatus(atSign) async {
    AtStatus atStatus;
    AtStatusImpl atStatusImpl;
    atStatusImpl = AtStatusImpl();

    atStatusImpl.rootUrl = 'test.do-sf2.atsign.zone';
    atStatus = await atStatusImpl.get(atSign);
    print('${atSign} status: ${atStatus.status()}');
    return atStatus;
  }

  await Future.forEach(atSigns, (element) async {
    await getAtStatus(element);
  });

  exit(0);
}

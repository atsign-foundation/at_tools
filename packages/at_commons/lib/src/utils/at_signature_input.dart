import 'package:at_commons/at_commons.dart';

///Bean type class to be used for passing data_signing related input information
class AtSignatureInput {
  ///data as String that is to be signed
  late String textToSign;
  ///RSA private key that is to be used to create the data_signature/digest
  ///When using at_platform it is preferred that the EncryptionPrivateKey of the signer atsign be used
  late String privateKey;
  ///Algorithm that is to be used to create the data_signature/digest
  late SignatureAlgorithm algorithm;
  ///Expected length of the digest [use 256 (or) 512]
  late int digestLength;
  ///Identity of the signer
  ///When using at_platform it is preferred that this be the atSign of the signer
  late String signedBy;
}
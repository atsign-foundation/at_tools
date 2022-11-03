///Bean type class to store data_signing related information
class AtSignature {
  ///data before signing
  late String actualText;
  ///data after signing
  late String signature;
  DateTime? signatureTimestamp;
  ///atsign/identity of the signer
  String? signedBy;
  ///details of the preferred algorithm and digest length to be used for signing
  late String signatureSpecification;

  @override
  String toString(){
    return 'actualText: $actualText\tsignature: $signature\ttimeStamp: $signatureTimestamp\tsignedBy: $signedBy\tsignatureSpecification: $signatureSpecification';
  }
}
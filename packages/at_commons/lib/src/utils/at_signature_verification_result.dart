///Bean type object used to pass data_signature/digest verification result
class AtSignatureVerificationResult {
  ///flag that indicates whether the signature is valid [true for valid / false for invalid]
  late bool isVerified;
  //To-Do - explore the possibility if expected signature can be constructed with RSAPrivateKey not being available
  String? expectedSignature;
  ///data_signature/digest used to verify the data
  String? actualSignature;
  ///Any exception encountered during signature/digest verification process
  Exception? exception;

  @override
  String toString() {
    return 'isVerified: $isVerified, expectedSignature: $expectedSignature, actualSignature: $actualSignature';
  }
}
import 'package:at_commons/at_commons.dart';

///Abstract class defining methods for signing and signature-veridying [AtValue]
abstract class AtDataSigning {
  ///Method that generates dataSignature for String [data] using an [RSAPrivateKey]
  ///
  ///Required Inputs:
  ///
  /// 1) String data that needs to be signed
  /// 2) [privateKey] of type RSAPrivateKey in a string format
  /// 3) Preferred algorithm to generate signature. Choose from algorithms specified in [SignatureAlgorithm]
  /// 4) Preffered length of signature
  ///
  ///Output: base64Encoded signature generated using [algorithm] and [digestLength]
  String signString(String data, String privateKey,
      SignatureAlgorithm algorithm, int digestLength);

  ///Method that generates dataSignature for type[AtSignatureInput] using an [RSAPrivateKey]
  ///
  ///Required Inputs:
  ///
  /// 1) [AtSignatureInput] object with all parameters specified
  ///
  ///Output:
  ///
  ///[AtSignature] object containing [signature], [signatureTimestamp] and [signedBy]
  ///signature is a base64Encoded String generated using algoritm and digestLength specified in [AtSignatureInput]
  AtSignature signWithObject(AtSignatureInput signatureInput);

  //////Verifies dataSignature in [data] to [signature] using [publicKey]
  ///
  ///Required inputs:
  ///1) data that needs to be verified using [signature]
  ///2) signature to be verified in base64Encoded String format
  ///3) publicKey of type [RSAPublicKey] belonging to the [RSAKeyPair] whose privateKey was used to generate signature
  ///4) Algorithm used to generate [signature]
  ///5) DigestLength used to generate [signature]
  ///
  ///Output:
  ///
  ///Case verified - Returns [AtSignatureVerificationResult] object with [AtSignatureVerificationResult.isVerified] set to true
  ///
  ///case NotVerified - Returns [AtSignatureVerificationResult] object with [AtSignatureVerificationResult.isVerified] set to false
  ///and the exception is stored in [AtSignatureVerificationResult.exception]
  bool verifySignature(String data, String signature, String publicKey,
      SignatureAlgorithm algorithm, int digestLength);

  ///Method that verifies dataSignature of object type [AtSignature] using [RSAPublicKey]
  ///
  ///Required inputs:
  ///1) [AtSignature] object containing all required parameters
  ///2) publicKey of type [RSAPublicKey] belonging to the [RSAKeyPair] whose privateKey was used to generate signature
  ///
  ///Verifies signature in [AtSignature.signature] to [AtSignature.actualText]
  ///
  ///Output:
  ///
  ///Case verified - Returns [AtSignatureVerificationResult] object with [AtSignatureVerificationResult.isVerified] set to true
  ///
  ///case NotVerified - Returns [AtSignatureVerificationResult] object with [AtSignatureVerificationResult.isVerified] set to false
  ///and the exception is stored in [AtSignatureVerificationResult.exception]
  AtSignatureVerificationResult verifySignatureObj(
      AtSignature signature, String publicKey);
}
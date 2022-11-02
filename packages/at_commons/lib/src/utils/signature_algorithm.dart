enum SignatureAlgorithm { sha2, sha3 }

///extension to get a properly formatted [SignatureSpecification]
///Usage:
///var sig_algo = SignatureAlgorithm.sha2
///sig_spec = sig_algo.getAlgorithm(512)
extension SignatureAlgorithmExtension on SignatureAlgorithm {
  String getAlgorithm(int length) {
    switch (this) {
      case SignatureAlgorithm.sha2:
        return 'SHA-2/$length';
      case SignatureAlgorithm.sha3:
        return 'SHA-3/$length';
    }
  }
  ///Method to parse a String type SignatureSpecification into a [SignatureSpecification] object
  static SignatureSpecification parseString(String raw) {
    switch (raw) {
      case 'SHA-2/256':
        return SignatureSpecification()
          ..algorithm = SignatureAlgorithm.sha2
          ..length = 256;
      case 'SHA-3/256':
        return SignatureSpecification()
          ..algorithm = SignatureAlgorithm.sha3
          ..length = 256;
      case 'SHA-3/512':
        return SignatureSpecification()
          ..algorithm = SignatureAlgorithm.sha3
          ..length = 512;
    }
    return SignatureSpecification()
      ..algorithm = SignatureAlgorithm.sha2
      ..length = 512;
  }
}

///Class to store the specification of the data_signing Signature
class SignatureSpecification {
  late SignatureAlgorithm algorithm;
  late int length;
}
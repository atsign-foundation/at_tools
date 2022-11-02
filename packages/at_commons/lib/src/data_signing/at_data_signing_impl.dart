import 'dart:convert';
import 'dart:typed_data';
import 'package:at_commons/at_commons.dart';
import 'package:crypton/crypton.dart' as crypton;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/export.dart' as pointy;
import 'package:pointycastle/signers/rsa_signer.dart';

class AtDataSigningImpl implements AtDataSigning {
  @override
  String signString(String data, String privateKey,
      SignatureAlgorithm algorithm, int digestLength) {
    return _getSignatureInternal(data, privateKey, algorithm, digestLength);
  }

  @override
  AtSignature signWithObject(AtSignatureInput signatureInput) {
    String signBase64 = _getSignatureInternal(
        signatureInput.textToSign,
        signatureInput.privateKey,
        signatureInput.algorithm,
        signatureInput.digestLength);

    return AtSignature()
      ..actualText = signatureInput.textToSign
      ..signature = signBase64
      ..signatureTimestamp = DateTime.now().toUtc()
      ..signedBy = signatureInput.signedBy
      ..signatureSpecification =
          signatureInput.algorithm.getAlgorithm(signatureInput.digestLength);
  }

  @override
  bool verifySignature(String data, String signature, String publicKey,
      SignatureAlgorithm algorithm, int digestLength) {
    return _verifySignatureInternal(
        data, signature, publicKey, algorithm, digestLength);
  }

  @override
  AtSignatureVerificationResult verifySignatureObj(
      AtSignature signature, String publicKey) {
    SignatureSpecification spec = SignatureAlgorithmExtension.parseString(
        signature.signatureSpecification);
    AtSignatureVerificationResult result = AtSignatureVerificationResult();
    result.isVerified = _verifySignatureInternal(signature.actualText,
        signature.signature, publicKey, spec.algorithm, spec.length);
    result.actualSignature = signature.signature;
    result.exception = SignatureMismatch();
    return result;
  }

  ///Method that formats input parameters from [signString] and [signWithObject] and calls [_generateRsaSign]
  String _getSignatureInternal(String data, String privateKey,
      SignatureAlgorithm algorithm, int digestLength) {
    _verifyDigestLength(digestLength);
    RSAPrivateKey rsaPrivateKey =
        crypton.RSAPrivateKey.fromString(privateKey).asPointyCastle;
    return base64Encode(_generateRsaSign(rsaPrivateKey,
        utf8.encode(data) as Uint8List, _getSigner(algorithm, digestLength)));
  }

  ///Method that formats input parameters from [verifySignature] and [verifySignatureObj] and calls [_verifyRsaSignature]
  bool _verifySignatureInternal(String data, String signature, String publicKey,
      SignatureAlgorithm algorithm, int digestLength) {
    _verifyDigestLength(digestLength);
    RSAPublicKey rsaPublicKey =
        crypton.RSAPublicKey.fromString(publicKey).asPointyCastle;
    return _verifyRsaSignature(
        rsaPublicKey,
        utf8.encode(signature) as Uint8List,
        utf8.encode(data) as Uint8List,
        _getSigner(algorithm, digestLength));
  }

  ///selects a [pointy.RSASigner] object based on [SignatureAlgorithm] and [digestLength]
  RSASigner _getSigner(SignatureAlgorithm algorithm, int digestLength) {
    if (algorithm == SignatureAlgorithm.sha2 && digestLength == 256) {
      return RSASigner(SHA256Digest(), '0609608648016503040201');
    } else if (algorithm == SignatureAlgorithm.sha2 && digestLength == 512) {
      return RSASigner(SHA512Digest(), '0609608648016503040203');
    } else if (algorithm == SignatureAlgorithm.sha3 && digestLength == 256) {
      return RSASigner(SHA256Digest(), '0609608648016503040201');
    }
    return RSASigner(SHA512Digest(), '0609608648016503040203');
  }

  ///Actual logic to generate an RSASignature using [RSAPrivateKey]
  Uint8List _generateRsaSign(
      RSAPrivateKey privateKey, Uint8List dataToSign, RSASigner signer) {
    //init RSASigner with forSigning=trure to sign data
    signer.init(true, PrivateKeyParameter<pointy.RSAPrivateKey>(privateKey));
    return signer.generateSignature(dataToSign).bytes;
  }

  ///Actual logic to verify [pointy.RSASignature] with [data] using [pointy.RSAPublicKey]
  bool _verifyRsaSignature(RSAPublicKey publicKey, Uint8List signature,
      Uint8List data, RSASigner verifier) {
    final sign = RSASignature(signature);
    //init RSASigner object with forSigning=false to verify signature
    verifier.init(false, PublicKeyParameter<pointy.RSAPublicKey>(publicKey));
    try {
      return verifier.verifySignature(data, sign);
    } on ArgumentError {
      return false;
    }
  }

  ///Method that ensures that the digestLength input to any caller method is 256/512
  void _verifyDigestLength(int length) {
    if (length != 256 && length != 512) {
      throw InvalidSyntaxException('$length is not a valid digest length');
    }
  }
}
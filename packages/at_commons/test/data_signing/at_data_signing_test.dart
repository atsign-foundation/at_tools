import 'dart:convert';
import 'dart:typed_data';

import 'package:at_commons/at_commons.dart';
import 'package:crypton/crypton.dart';
import 'package:test/test.dart';

void main() {
  group('test dataSignature creation using object for SHA-2/256', () {
    AtDataSigning atDataSigning = AtDataSigningImpl();
    RSAKeypair dummyKeyPair = RSAKeypair.fromRandom();
    AtSignature? signedObj;
    String clearText = 'test1';

    AtSignatureInput input = AtSignatureInput();
    input.privateKey = dummyKeyPair.privateKey.toString();
    input.algorithm = SignatureAlgorithm.sha2;
    input.digestLength = 256;
    input.signedBy = 'unit_test';
    input.textToSign = clearText;

    test('test signature creation', () {
      signedObj = atDataSigning.signWithObject(input);
      expect(
          signedObj?.signature,
          base64Encode(dummyKeyPair.privateKey
              .createSHA256Signature(utf8.encode(clearText) as Uint8List)));
    });

    test('test signature verification - case: verified', () {
      AtSignatureVerificationResult testResult = atDataSigning
          .verifySignatureObject(signedObj!, dummyKeyPair.publicKey.toString());
      expect(signedObj?.actualText, clearText);
      expect(testResult.isVerified, true);
      expect(testResult.exception, null);
      expect(
          testResult.actualSignature,
          base64Encode(dummyKeyPair.privateKey
              .createSHA256Signature(utf8.encode(clearText) as Uint8List)));
    });

    test('test signature verification - case: not verified', () {
      //injecting random signature to assert signature mismatch
      signedObj?.signature =
          'CnbuPizWxdyzkBuoHccQinR8BFg90ewYFsUN2/wEFoHtoOpXQ6jugkud624OkwFNMHDQAGyTd/l7ngxrXMHz4/D/36zVdy+HWSy0aGsOR5Apphc6wcG1SChnrTSGNXZISVd4bpJNM5W/N1h5RYN2RnxnQEpCy3Z0SglHIZ+ZKeDhDLEa5L2rpGIGz8PkUkDREc5LUTrseq5NgU71zyYbdYb7581ELq6eK+DpseHmdbS6divIUUuNkxHJcw3MU8a5hkzNfyvc1+9Y+mbpLZ2r9i+zkNHyqbHxlJTGjM5qyRDz9/fjD02zYKSnAEbhxeuovf5VV1A1+TgukI+3kY8CKA==';
      AtSignatureVerificationResult testResult = atDataSigning
          .verifySignatureObject(signedObj!, dummyKeyPair.publicKey.toString());
      expect(signedObj?.actualText, clearText);
      expect(testResult.isVerified, false);
      expect(testResult.exception.toString(), SignatureMismatch().toString());
    });
  });

  group(
      'test signature creation and verification using string methods SHA-2/256',
      () {
    AtDataSigning atDataSigning = AtDataSigningImpl();
    RSAKeypair dummyKeyPair = RSAKeypair.fromRandom();
    String clearText = 'test2';
    String? digest;

    test('test signature creation', () {
      digest = atDataSigning.signString(clearText,
          dummyKeyPair.privateKey.toString(), SignatureAlgorithm.sha2, 256);
      expect(
          digest,
          base64Encode(dummyKeyPair.privateKey
              .createSHA256Signature(utf8.encode(clearText) as Uint8List)));
    });

    test('test signature verification - case: verified', () {
      expect(
          atDataSigning.verifyStringSignature(clearText, digest!,
              dummyKeyPair.publicKey.toString(), SignatureAlgorithm.sha2, 256),
          true);
    });

    test('test signature verification - case: not verified', () {
      //injecting random signature to assert signature mismatch
      digest =
          'ZaYLZKug13QCuFrqRvrvZ78ZiwZflQc2LdX9vZS6n6Us9A0kzwsJP/3FvWkd+TOK2VaoAkfyI5CiS5by8y2H1e1mfnBOSWD5dEuLea4280RzTfRn7IzIoPZlSTmN7GpB4S7nYZBgI27lPdhy8WArgMcAOMgd5BhsLkxZnQ+6tQDoDg1RuFCjuFzy9hlUa2Uq0R7Wl+dsUB6tENPj4TkLcdxwPOpGFOFHhncpz/rmRamt+fES8jjyStEK70gFMTb1W/MbwE75FFwbtboDjY3AG4RMrFKcnkqgAFaUfK0c3aOmhsSEPrToHyjj/ZolofWjmCzNS8N0ttCwcGm3rba/AA==';
      expect(
          atDataSigning.verifyStringSignature(clearText, digest!,
              dummyKeyPair.publicKey.toString(), SignatureAlgorithm.sha2, 256),
          false);
    });
  });

  group('test dataSignature creation using object for SHA-2/512', () {
    AtDataSigning atDataSigning = AtDataSigningImpl();
    RSAKeypair dummyKeyPair = RSAKeypair.fromRandom();
    AtSignature? signedObj;
    String clearText = 'test21';

    AtSignatureInput input = AtSignatureInput();
    input.privateKey = dummyKeyPair.privateKey.toString();
    input.algorithm = SignatureAlgorithm.sha2;
    input.digestLength = 512;
    input.signedBy = 'unit_test512';
    input.textToSign = clearText;

    test('test signature creation', () {
      signedObj = atDataSigning.signWithObject(input);
      expect(
          signedObj?.signature,
          base64Encode(dummyKeyPair.privateKey
              .createSHA512Signature(utf8.encode(clearText) as Uint8List)));
    });

    test('test signature verification - case: verified', () {
      AtSignatureVerificationResult testResult = atDataSigning
          .verifySignatureObject(signedObj!, dummyKeyPair.publicKey.toString());
      expect(signedObj?.actualText, clearText);
      expect(testResult.isVerified, true);
      expect(testResult.exception, null);
      expect(
          testResult.actualSignature,
          base64Encode(dummyKeyPair.privateKey
              .createSHA512Signature(utf8.encode(clearText) as Uint8List)));
    });

    test('test signature verification - case: not verified', () {
      //injecting random signature to assert signature mismatch
      signedObj?.signature =
          'CnbuPizWxdyzkBuoHccQinR8BFg90ewYFsUN2/wEFoHtoOpXQ6jugkud624OkwFNMHDQAGyTd/l7ngxrXMHz4/D/36zVdy+HWSy0aGsOR5Apphc6wcG1SChnrTSGNXZISVd4bpJNM5W/N1h5RYN2RnxnQEpCy3Z0SglHIZ+ZKeDhDLEa5L2rpGIGz8PkUkDREc5LUTrseq5NgU71zyYbdYb7581ELq6eK+DpseHmdbS6divIUUuNkxHJcw3MU8a5hkzNfyvc1+9Y+mbpLZ2r9i+zkNHyqbHxlJTGjM5qyRDz9/fjD02zYKSnAEbhxeuovf5VV1A1+TgukI+3kY8CKA==';
      AtSignatureVerificationResult testResult = atDataSigning
          .verifySignatureObject(signedObj!, dummyKeyPair.publicKey.toString());
      expect(signedObj?.actualText, clearText);
      expect(testResult.isVerified, false);
      expect(testResult.exception.toString(), SignatureMismatch().toString());
    });
  });

  group(
      'test signature creation and verification using string methods SHA-2/512',
      () {
    AtDataSigning atDataSigning = AtDataSigningImpl();
    RSAKeypair dummyKeyPair = RSAKeypair.fromRandom();
    String clearText = 'test2';
    String? digest;

    test('test signature creation', () {
      digest = atDataSigning.signString(clearText,
          dummyKeyPair.privateKey.toString(), SignatureAlgorithm.sha2, 512);
      expect(
          digest,
          base64Encode(dummyKeyPair.privateKey
              .createSHA512Signature(utf8.encode(clearText) as Uint8List)));
    });

    test('test signature verification - case: verified', () {
      expect(
          atDataSigning.verifyStringSignature(clearText, digest!,
              dummyKeyPair.publicKey.toString(), SignatureAlgorithm.sha2, 512),
          true);
    });

    test('test signature verification - case: not verified', () {
      //injecting random signature to assert signature mismatch
      digest =
          'ZaYLZKug13QCuFrqRvrvZ78ZiwZflQc2LdX9vZS6n6Us9A0kzwsJP/3FvWkd+TOK2VaoAkfyI5CiS5by8y2H1e1mfnBOSWD5dEuLea4280RzTfRn7IzIoPZlSTmN7GpB4S7nYZBgI27lPdhy8WArgMcAOMgd5BhsLkxZnQ+6tQDoDg1RuFCjuFzy9hlUa2Uq0R7Wl+dsUB6tENPj4TkLcdxwPOpGFOFHhncpz/rmRamt+fES8jjyStEK70gFMTb1W/MbwE75FFwbtboDjY3AG4RMrFKcnkqgAFaUfK0c3aOmhsSEPrToHyjj/ZolofWjmCzNS8N0ttCwcGm3rba/AA==';
      expect(
          atDataSigning.verifyStringSignature(clearText, digest!,
              dummyKeyPair.publicKey.toString(), SignatureAlgorithm.sha2, 512),
          false);
    });
  });
}
class SignatureNotFound implements Exception {
  String message = 'DataSignature field of MetaData is null';
}

class SignatureMismatch implements Exception {
  String message =
      'DataSignature invalid. Data (or) signature has been modified';
}
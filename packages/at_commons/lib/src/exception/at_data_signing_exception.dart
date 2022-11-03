class SignatureMismatch implements Exception {
  String message =
      'DataSignature invalid. Data (or) signature has been modified';
}

class AlgorithmNotFound implements Exception{
  late String message;
  AlgorithmNotFound(String algorithm){
    message = 'Algorithm $algorithm creating/verifying dataSignature cannot be identified';
  }
}
enum KeyType {
  selfKey,
  sharedKey,
  publicKey,
  privateKey,
  cachedPublicKey,
  cachedSharedKey,
  reservedKey,
  invalidKey
}

enum ReservedKey {
  encryptionSharedKey,
  encryptionPublicKey,
  encryptionPrivateKey,
  pkamPublicKey,
  signingPrivateKey,
  signingPublicKey,
  nonReservedKey
}

class TestKeys {
  List<String> validPublicKeys = [];
  List<String> invalidPublicKeys = [];
  List<String> validPrivateKeys = [];
  List<String> invalidPrivateKeys = [];
  List<String> validSharedKeys = [];
  List<String> invalidSharedKeys = [];
  List<String> validSelfKeys = [];
  List<String> invalidSelfKeys = [];
  List<String> validCachedPublicKeys = [];
  List<String> invalidCachedPublicKeys = [];
  List<String> validCachedSharedKeys = [];
  List<String> invalidCachedSharedKeys = [];

  TestKeys({bool includeNonBobKeys = true}) {
    _init(includeNonBobKeys);
  }

  _init(bool includeNonBobKeys) {
    _initValidPublicKeys();
    _initInvalidPublicKeys();

    _initValidPrivateKeys();
    _initInvalidPrivateKeys();

    _initValidCachedPublicKeys();
    _initInvalidCachedPublicKeys();

    _initValidSelfKeys();
    _initInvalidSelfKeys();

    _initValidSharedKeys();
    _initInvalidSharedKeys();

    _initValidCachedSharedKeys();
    _initInvalidCachedSharedKeys();

    if (includeNonBobKeys) {
      _initNonBobPublicKeys();
      _initNonBobPrivateKeys();
      _initNonBobCachedPublicKeys();
      _initNonBobSelfKeys();
      _initNonBobSharedKeys();
      _initNonBobCachedSharedKeys();
    }
  }

  _initNonBobPublicKeys() {
    // public key with max of 55 characters for the @sign
    validPublicKeys.add(
        "public:@bob0123456789012345678901234567890123456789012345:phone.buzz@bob0123456789012345678901234567890123456789012345");
    // public key with valid punctuations in the @sign
    validPublicKeys.add("public:@jagann_a-d_h:phone.buzz@jagann_a-d_h");
    // public key with emoji's in @sign
    validPublicKeys.add("public:@bob💙:phone.buzz@bob💙");
    // Emojis in both @sign and entity
    validPublicKeys.add("public:@bob💙:phone😀.buzz@bob💙");

    // More than 55 characters for the @sign
    invalidPublicKeys.add(
        "public:@bob0123456789012345678901234567890123456789012345extrachars:phone.buzz@bob0123456789012345678901234567890123456789012345extrachars");
    //  Invalid punctuations in the @sign
    invalidPublicKeys.add("public:@bo#b:phone.buzz@bo#b");
    //  Invalid and valid punctuations in the @sign
    invalidPublicKeys.add("public:@jagan_____na#dh💙:phone.buzz@bob💙");
  }

  _initValidPublicKeys() {
    // public key with sharedWith specified
    validPublicKeys.add("public:@bob:phone.buzz@bob");
    //  public key with sharedWith not being specified
    validPublicKeys.add("public:phone.buzz@bob");
    //  public key with sharedWith specified and single character entity and namespace
    validPublicKeys.add("public:@bob:p.b@bob");
    //  public key with single character entity and namespace
    validPublicKeys.add("public:p.b@bob");
    //  public key with punctuations in the entity name
    validPublicKeys.add("public:pho_-ne.b@bob");
    //  public key with single character entity and namespace
    validPublicKeys.add("public:p.b@bob");
    //  public key with punctuations in the entity name
    validPublicKeys.add("public:pho_-ne.b@bob");
    // public key with many punctuations in the entity name
    validPublicKeys.add("public:pho_-n________e.b@bob");
    //  public key with emoji's in entity
    validPublicKeys.add("public:@bob:phone😀.buzz@bob");
  }

  _initInvalidPublicKeys() {
    // Misspelt public
    invalidPublicKeys.add("publicc:@bob:phone.buzz@bob");
    //  No public
    invalidPublicKeys.add("phone.buzz@bob");
    //  No namespace
    invalidPublicKeys.add("public:@bob:phone@bob");
    //  No public and start with a :
    invalidPublicKeys.add(":phone.buzz@bob");
    //  Invalid punctuations in the entity name
    invalidPublicKeys.add("public:pho#ne.b@bob");
    // Valid and invalid punctuations together
    invalidPublicKeys.add("public:pho#n____-____e.b@bob");
    // Key with no atsign
    invalidPublicKeys.add("public:pho#n____-____e.b");
    // key without entity
    invalidPublicKeys.add("public:@bob");
  }

  _initNonBobPrivateKeys() {
    // private key with max of 55 characters for the @sign
    validPrivateKeys.add(
        "private:@bob0123456789012345678901234567890123456789012345:phone.buzz@bob0123456789012345678901234567890123456789012345");
    //  private key with valid punctuations in the @sign
    validPrivateKeys.add("private:@jagann_a-d_h:phone.buzz@jagann_a-d_h");
    //  private key with emoji's in @sign
    validPrivateKeys.add("private:@bob💙:phone.buzz@bob💙");
    // 1Emoji in both @sign and entity
    validPrivateKeys.add("private:@bob💙:phone😀.buzz@bob💙");
    //  Invalid punctuations in the @sign
    invalidPrivateKeys.add("private:@bo#b:phone.buzz@bo#b");
    //  Invalid and valid punctuations in the @sign
    invalidPrivateKeys.add("private:@jagan_____na#dh💙:phone.buzz@bob💙");
  }

  _initValidPrivateKeys() {
    // private key with sharedWith specified
    validPrivateKeys.add("private:@bob:phone.buzz@bob");
    //  private key with sharedWith not specified
    validPrivateKeys.add("private:phone.buzz@bob");
    //  private key with sharedWith specified and single character entity and namespace
    validPrivateKeys.add("private:@bob:p.b@bob");
    //  private key with single character entity and namespace
    validPrivateKeys.add("private:p.b@bob");
    //  private key with punctuations in the entity name
    validPrivateKeys.add("private:pho_-ne.b@bob");
    // private key with many punctuations in the entity name
    validPrivateKeys.add("private:pho_-n________e.b@bob");
    //  private key with emoji's in entity
    validPrivateKeys.add("private:@bob:phone😀.buzz@bob");
  }

  _initInvalidPrivateKeys() {
    // Misspelt private
    invalidPrivateKeys.add("privateeee:@bob:phone.buzz@bob");
    //  No private
    invalidPrivateKeys.add("phone.buzz@bob");
    //  No namespace
    invalidPrivateKeys.add("private:@bob:phone@bob");
    //  No private and start with a :
    invalidPrivateKeys.add(":phone.buzz@bob");
    //  Invalid punctuations in the entity name
    invalidPrivateKeys.add("private:pho#ne.b@bob");
    // Valid and invalid punctuations together
    invalidPrivateKeys.add("private:pho#n____-____e.b@bob");
    // More than 55 characters for the @sign
    invalidPrivateKeys.add(
        "private:@bob0123456789012345678901234567890123456789012345extracharshere:phone.buzz@bob");
  }

  _initNonBobCachedPublicKeys() {
    // cached public key with max of 55 characters for the @sign
    validCachedPublicKeys.add(
        "cached:public:@bob0123456789012345678901234567890123456789012345:phone.buzz@bob0123456789012345678901234567890123456789012345");
    //  cached public key with valid punctuations in the @sign
    validCachedPublicKeys
        .add("cached:public:@jagann_a-d_h:phone.buzz@jagann_a-d_h");
    //  cached public key with emoji's in @sign
    validCachedPublicKeys.add("cached:public:@bob💙:phone.buzz@bob💙");
    // cached public public in both @sign and entity
    validCachedPublicKeys.add("cached:public:@bob💙:phone😀.buzz@bob💙");
    //  Invalid and valid punctuations in the @sign
    invalidCachedPublicKeys
        .add("cached:public:@jagan_____na#dh💙:phone.buzz@bob💙");
  }

  _initValidCachedPublicKeys() {
    // cached public key with sharedWith specified
    validCachedPublicKeys.add("cached:public:@bob:phone.buzz@bob");
    //  cached public key with sharedWith not being specified
    validCachedPublicKeys.add("cached:public:phone.buzz@bob");
    //  cached public key with sharedWith specified and single character entity and namespace
    validCachedPublicKeys.add("cached:public:@bob:p.b@bob");
    //  cached public key with single character entity and namespace
    validCachedPublicKeys.add("cached:public:p.b@bob");
    //  cached public key with punctuations in the entity name
    validCachedPublicKeys.add("cached:public:pho_-ne.b@bob");
    // cached public key with many punctuations in the entity name
    validCachedPublicKeys.add("cached:public:pho_-n________e.b@bob");
    //  cached public key with emoji's in entity
    validCachedPublicKeys.add("cached:public:@bob:phone😀.buzz@bob");
  }

  _initInvalidCachedPublicKeys() {
    // Mis-spelt public
    invalidCachedPublicKeys.add("cached:publicc:@bob:phone.buzz@bob");
    //  No cached public
    invalidCachedPublicKeys.add("phone.buzz@bob");
    //  No namespace
    invalidCachedPublicKeys.add("cached:public:@bob:phone@bob");
    //  No cached public and start with a :
    invalidCachedPublicKeys.add(":phone.buzz@bob");
    //  Invalid punctuations in the entity name
    invalidCachedPublicKeys.add("cached:public:pho#ne.b@bob");
    // Valid and invalid punctuations together
    invalidCachedPublicKeys.add("cached:public:pho#n____-____e.b@bob");
    // More than 55 characters for the @sign
    invalidCachedPublicKeys.add(
        "cached:public:@bob0123456789012345678901234567890123456789012345extracharshere:phone.buzz@bob");
    //  Invalid punctuations in the @sign
    invalidCachedPublicKeys.add("cached:public:@jaganna#dh:phone.buzz@bob");
  }

  _initNonBobSelfKeys() {
    // Self key with max of 55 characters for the @sign
    validSelfKeys.add(
        "@bob0123456789012345678901234567890123456789012345:phone.buzz@bob0123456789012345678901234567890123456789012345");
    //  Self key with valid punctuations in the @sign
    validSelfKeys.add("@jagann_a-d_h:phone.buzz@jagann_a-d_h");
    //  Self key with emoji's in @sign
    validSelfKeys.add("@bob💙:phone.buzz@bob💙");
    // 1Self key with emojis in both @sign and entity
    validSelfKeys.add("@bob💙:phone😀.buzz@bob💙");
    // Invalid and valid punctuations in the @sign
    invalidSelfKeys.add("@jagan_____na#dh💙:phone.buzz@bob💙");
  }

  _initValidSelfKeys() {
    // Self key with shared with specified
    validSelfKeys.add("@bob:phone.buzz@bob");
    //  Self key with sharedWith not being specified
    validSelfKeys.add("phone.buzz@bob");
    //  Self key with sharedWith specified and single character entity and namespace
    validSelfKeys.add("@bob:p.b@bob");
    //  Self key with single character entity and namespace
    validSelfKeys.add("p.b@bob");
    //  Self key with punctuations in the entity name
    validSelfKeys.add("pho_-ne.b@bob");
    // Self key with many punctuations in the entity name
    validSelfKeys.add("pho_-n________e.b@bob");
    //  Self key with emoji's in entity
    validSelfKeys.add("@bob:phone😀.buzz@bob");
  }

  _initInvalidSelfKeys() {
    // No namespace
    invalidSelfKeys.add("@bob:phone@bob");
    //  Starts with a :
    invalidSelfKeys.add(":phone.buzz@bob");
    //  Invalid punctuations in the entity name
    invalidSelfKeys.add("@bob:pho#ne.b@bob");
    //  Valid and invalid punctuations together
    invalidSelfKeys.add("@bob:pho#n____-____e.b@bob");
    //  More than 55 characters for the @sign
    invalidSelfKeys.add(
        "@bob0123456789012345678901234567890123456789012345extracharshere:phone.buzz@bob");
    // Invalid punctuations in the @sign
    invalidSelfKeys.add("@jaganna#dh:phone.buzz@bob");
  }

  _initNonBobSharedKeys() {
    // Shared key with max of 55 characters for the @sign
    validSharedKeys.add(
        "@alice0123456789012345678901234567890123456789012345:phone.buzz@bob");
    // Shared key with valid punctuations in the @sign
    validSharedKeys.add("@sita_ram:phone.buzz@jagann_a-d_h");
    //  Shared key with emoji's in @sign
    validSharedKeys.add("@alice💙:phone.buzz@bob💙");
    //  Shared key with emojis in both @sign and entity
    validSharedKeys.add("@alice💙:phone😀.buzz@bob💙");
    // Invalid and valid punctuations in the @sign
    invalidSharedKeys.add("@sita_____ra#m💙:phone.buzz@bob💙");
  }

  _initValidSharedKeys() {
    // Shared key with shared with specified
    validSharedKeys.add("@alice:phone.buzz@bob");
    //  Shared key with sharedWith specified and single character entity and namespace
    validSharedKeys.add("@alice:p.b@bob");
    //  Shared key with single character entity and namespace
    validSharedKeys.add("@alice:p.b@bob");
    //  Shared key with punctuations in the entity name
    validSharedKeys.add("@alice:pho_-ne.b@bob");
    //  Shared key with many punctuations in the entity name
    validSharedKeys.add("@alice:pho_-n________e.b@bob");
    //  Shared key with emoji's in entity
    validSharedKeys.add("@alice:phone😀.buzz@bob");
  }

  _initInvalidSharedKeys() {
    // No namespace
    invalidSharedKeys.add("@alice:phone@bob");
    //  Starts with a :
    invalidSharedKeys.add(":phone.buzz@bob");
    //  Invalid punctuations in the entity name
    invalidSharedKeys.add("@alice:pho#ne.b@bob");
    //  Valid and invalid punctuations together
    invalidSharedKeys.add("@alice:pho#n____-____e.b@bob");
    //  More than 55 characters for the @sign
    invalidSharedKeys.add(
        "@alicemm0123456789012345678901234567890123456789012345extracharshere:phone.buzz@bob");
    // Invalid punctuations in the @sign
    invalidSharedKeys.add("@sita#ram:phone.buzz@bob");
  }

  _initNonBobCachedSharedKeys() {
    // Cached shared key with valid punctuations in the @sign
    validCachedSharedKeys.add("cached:@sita_ram:phone.buzz@jagann_a-d_h");
    //  Cached shared key with emoji's in @sign
    validCachedSharedKeys.add("cached:@alice💙:phone.buzz@bob💙");
    //  Cached shared key with emojis in both @sign and entity
    validCachedSharedKeys.add("cached:@alice💙:phone😀.buzz@bob💙");
    // Invalid and valid punctuations in the @sign
    invalidCachedSharedKeys.add("cached:@sita_____ra#m💙:phone.buzz@bob💙");
  }

  _initValidCachedSharedKeys() {
    // Cached shared key with shared with specified
    validCachedSharedKeys.add("cached:@bob:phone.buzz@alice");
    // Cached shared key with sharedWith specified and single character entity and namespace
    validCachedSharedKeys.add("cached:@bob:p.b@alice");
    //  Cached shared key with single character entity and namespace
    validCachedSharedKeys.add("cached:@bob:p.b@alice");
    //  Cached shared key with punctuations in the entity name
    validCachedSharedKeys.add("cached:@bob:pho_-ne.b@alice");
    //  Cached shared key with many punctuations in the entity name
    validCachedSharedKeys.add("cached:@bob:pho_-n________e.b@alice");
    // Cached shared key with max of 55 characters for the @sign
    validCachedSharedKeys.add(
        "cached:@alice0123456789012345678901234567890123456789012345:phone.buzz@alice");
    //  Cached shared key with emoji's in entity
    validCachedSharedKeys.add("cached:@alice:phone😀.buzz@alice");
  }

  _initInvalidCachedSharedKeys() {
    // No namespace
    invalidCachedSharedKeys.add("cached:@alice:phone@bob");
    //  Starts with a :
    invalidCachedSharedKeys.add(":phone.buzz@bob");
    //  Invalid punctuations in the entity name
    invalidCachedSharedKeys.add("cached:@alice:pho#ne.b@bob");
    //  Valid and invalid punctuations together
    invalidCachedSharedKeys.add("cached:@alice:pho#n____-____e.b@bob");
    //  More than 55 characters for the @sign
    invalidCachedSharedKeys.add(
        "cached:@alicemm0123456789012345678901234567890123456789012345extracharshere:phone.buzz@bob");
    // Invalid punctuations in the @sign
    invalidCachedSharedKeys.add("cached:@sita#ram:phone.buzz@bob");
  }
}

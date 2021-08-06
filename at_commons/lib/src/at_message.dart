enum AtMessage {
  wrongVerb,
  closingConnection,
  cleanExit,
  moreThanOneAt,
  whiteSpaceNotAllowed,
  reservedCharacterUsed,
  noAtSign,
  controlCharacter,
}

extension AtMessageExtension on AtMessage {
  String get text {
    const String _notFoundMsg = 'No message found';
    const String _wrongVerbMsg =
        'Available verbs are: lookup:, from:, pol:, llookup:, plookup:, update:, delete:, scan and exit. ';
    const String _closingConnectionMsg = 'Closing the connection. ';
    const String _cleanExitMsg = 'Exited cleanly, closing the connection. ';
    const String _moreThanOneAt =
        'invalid @sign: Cannot Contain more than one @ character';
    const String _whiteSpaceNotAllowed =
        'invalid @sign: Cannot Contain whitespace characters';
    const String _reservedCharacterUsed =
        'invalid @sign: Cannot contain !*\'`();:&=+\$,/?#[]{}\\ characters';
    const String _noAtSign =
        'invalid @sign: must include one @ character and at least one character on the right';
    const String _controlCharacter =
        'invalid @sign: must not include control characters';

    switch (this) {
      case AtMessage.wrongVerb:
        return _wrongVerbMsg;
      case AtMessage.closingConnection:
        return _closingConnectionMsg;
      case AtMessage.cleanExit:
        return _cleanExitMsg;
      case AtMessage.moreThanOneAt:
        return _moreThanOneAt;
      case AtMessage.whiteSpaceNotAllowed:
        return _whiteSpaceNotAllowed;
      case AtMessage.reservedCharacterUsed:
        return _reservedCharacterUsed;
      case AtMessage.noAtSign:
        return _noAtSign;
      case AtMessage.controlCharacter:
        return _controlCharacter;
      default:
        return _notFoundMsg;
    }
  }
}

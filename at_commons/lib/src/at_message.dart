// ignore_for_file: unnecessary_string_escapes
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
    const _notFoundMsg = 'No message found';
    const _wrongVerbMsg =
        'Available verbs are: lookup:, from:, pol:, llookup:, plookup:, update:, delete:, scan and exit. ';
    const _closingConnectionMsg = 'Closing the connection. ';
    const _cleanExitMsg = 'Exited cleanly, closing the connection. ';
    const _moreThanOneAt =
        'invalid @sign: Cannot Contain more than one @ character';
    const _whiteSpaceNotAllowed =
        'invalid @sign: Cannot Contain whitespace characters';
    const _reservedCharacterUsed =
        'invalid @sign: Cannot contain \!\*\'`\(\)\;\:\&\=\+\$\,\/\?\#\[\]\{\} characters';
    const _noAtSign =
        'invalid @sign: must include one @ character and at least one character on the right';
    const _controlCharacter =
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

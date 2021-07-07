import 'package:at_commons/at_commons.dart';

class Response {
  String? _data;
  String? _type;
  bool _isError = false;
  String? _errorMessage;
  String? errorCode;
  AtException? atException;

  // ignore: unnecessary_getters_setters
  bool get isError => _isError;

  bool isStream = false;

  Response();

  Response.factory(this._data, this.errorCode, this._errorMessage);

  factory Response.fromJson(dynamic json) {
    return Response.factory(json['data'] as String?,
        json['error_code'] as String?, json['error_message'] as String?);
  }

  Map toJson() {
    var jsonMap = {};
    if (_data != null) {
      jsonMap['data'] = _data;
    }
    if (errorCode != null) {
      jsonMap['error_code'] = errorCode;
    }
    if (_errorMessage != null) {
      jsonMap['error_message'] = _errorMessage;
    }
    return jsonMap;
  }

  @override
  String toString() {
    return 'Response{_data: $_data, _type: $_type, _isError: $_isError, _errorMessage: $_errorMessage}';
  }

  // ignore: unnecessary_getters_setters
  set isError(bool value) {
    _isError = value;
  }

  // ignore: unnecessary_getters_setters
  String? get errorMessage => _errorMessage;

  // ignore: unnecessary_getters_setters
  set errorMessage(String? value) {
    _errorMessage = value;
  }

  // ignore: unnecessary_getters_setters
  String? get type => _type;

  // ignore: unnecessary_getters_setters
  set type(String? value) {
    _type = value;
  }

  // ignore: unnecessary_getters_setters
  String? get data => _data;

  // ignore: unnecessary_getters_setters
  set data(String? value) {
    _data = value;
  }
}

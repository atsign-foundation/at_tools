import 'package:at_commons/at_commons.dart';

class Response {
  String _data;
  String _type;
  bool _isError = false;
  String _errorMessage;
  String errorCode;
  AtException atException;

  bool get isError => _isError;

  bool isStream = false;

  Response();

  Response.factory(this._data, this.errorCode, this._errorMessage);

  factory Response.fromJson(dynamic json) {
    return Response.factory(json['data'] as String,
        json['error_code'] as String, json['error_message'] as String);
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
    return 'Response{_data: ${_data}, _type: $_type, _isError: $_isError, _errorMessage: $_errorMessage}';
  }

  set isError(bool value) {
    _isError = value;
  }

  String get errorMessage => _errorMessage;

  set errorMessage(String value) {
    _errorMessage = value;
  }

  String get type => _type;

  set type(String value) {
    _type = value;
  }

  String get data => _data;

  set data(String value) {
    _data = value;
  }
}

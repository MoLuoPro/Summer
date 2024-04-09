library http;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

part './request_handler.dart';
part './http_method.dart';
part './server.dart';
part './final_handler.dart';

class HttpRequestWrapper {
  Map<String, dynamic> params = {};
  final HttpRequest _request;

  HttpRequestWrapper(this._request);

  Stream<Uint8List> get stream => _request;
  Map<String, String> get queryParameters => _request.uri.queryParameters;
  Uri get uri => _request.uri;
  String get method => _request.method;
}

class HttpResponsetWrapper {
  int _statusCode;
  final HttpResponse _response;

  HttpResponsetWrapper(this._response, this._statusCode);

  int get statusCode => _statusCode;
  set statusCode(int value) {
    _statusCode = value;
    _response.statusCode = value;
  }

  write(Object object) => _response.write(object);

  writeAll(Iterable<dynamic> objects, [String separator = ""]) =>
      _response.writeAll(objects, separator);

  writeln([Object? object = ""]) => _response.writeln(object);

  writeCharCode(int charCode) => _response.writeCharCode(charCode);
}

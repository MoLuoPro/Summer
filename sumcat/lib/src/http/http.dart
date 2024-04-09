library http;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

part './request_handler.dart';
part './http_method.dart';
part './server.dart';
part './final_handler.dart';

class HttpRequestWrapper {
  final Map<String, dynamic> _params = {};
  final HttpRequest _request;

  HttpRequestWrapper(this._request);

  Stream<Uint8List> get stream => _request;
  Map<String, dynamic> get params => _params;
  Map<String, String> get queryParameters => _request.uri.queryParameters;
  Uri get uri => _request.uri;
  String get method => _request.method;
  int get contentLength => _request.contentLength;
  Uri get requestedUri => _request.requestedUri;
  HttpHeaders get headers => _request.headers;
  List<Cookie> get cookies => _request.cookies;
  bool get persistentConnection => _request.persistentConnection;
  X509Certificate? get certificate => _request.certificate;
  HttpSession get session => _request.session;
  String get protocolVersion => _request.protocolVersion;
  HttpConnectionInfo? get connectionInfo => _request.connectionInfo;
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

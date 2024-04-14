library http;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

part './request_handler.dart';
part './methods.dart';
part './server.dart';
part './final_handler.dart';
part './error/error.dart';

///对[HttpRequest]的封装
class Request {
  final Map<String, dynamic> _params = {};
  final HttpRequest _inner;
  Map<String, String> _body = {};
  String _baseUrl = '';

  Request(this._inner);

  HttpHeaders get headers => _inner.headers;
  Uri get uri => _inner.uri;
  String get encoding => headers.contentType?.charset ?? '';
  String get method => _inner.method;
  String get protocolVersion => _inner.protocolVersion;
  Map<String, dynamic> get params => _params;
  Map<String, String> get query => uri.queryParameters;
  Future<Map<String, String>> get body => decodingBody();

  Future<Map<String, String>> decodingBody() async {
    if (_body.isNotEmpty) {
      return _body;
    }
    var data = await decoding();
    String json = data.containsKey('_value') ? data['_value']! : '';
    _body = jsonDecode(json);
    return _body;
  }

  Future<Map<String, String>> decoding() async {
    if (_dataType() == 'json') {
      switch (encoding) {
        case 'utf-8':
          return await _utf8JsonDecoding();
      }
    } else if (_dataType() == 'x-www-form-urlencoded') {
      switch (encoding) {
        case 'utf-8':
          return await _utf8FormDecoding();
      }
    }
    return {};
  }

  String? _dataType() {
    return headers.contentType?.subType;
  }

  Future<Map<String, String>> _utf8JsonDecoding() async {
    var json = await utf8.decoder.bind(_inner).join();
    return jsonDecode(json);
  }

  Future<Map<String, String>> _utf8FormDecoding() async {
    var query = await utf8.decoder.bind(_inner).join();
    return Uri.splitQueryString(query);
  }
}

class RequestInternal extends Request {
  HttpRequest get inner => _inner;
  WebSocket? _ws;
  RequestInternal(HttpRequest inner) : super(inner);
  String get baseUrl => _baseUrl;
  set baseUrl(value) => _baseUrl = value;
  WebSocket? get ws => _ws;
  set ws(WebSocket? value) => _ws = value;
}

///对[HttpResponse]的封装
class Response {
  final HttpResponse _inner;

  Response(this._inner);

  int get statusCode => _inner.statusCode;
  HttpHeaders get headers => _inner.headers;
  List<Cookie> get cookies => _inner.cookies;
  Encoding get encoding => _inner.encoding;

  Future<dynamic> redirect(Uri location,
          {int status = HttpStatus.movedTemporarily}) =>
      _inner.redirect(location, status: status);

  Response ok(
      [String json = '',
      String contentType = 'application/json charset=utf-8']) {
    _inner.statusCode = 200;
    _inner.write(json);
    return this;
  }

  Response error(
      [String message = 'error!',
      int statusCode = HttpStatus.internalServerError]) {
    _inner.statusCode = statusCode;
    _inner.write(message);
    return this;
  }

  Response json(Map<String, dynamic> data, int statusCode) {
    _inner.statusCode = statusCode;
    _inner.write(jsonEncode(data));
    return this;
  }

  Response string(String string, int statusCode) {
    _inner.statusCode = statusCode;
    _inner.write(string);
    return this;
  }
}

class ResponseInternal extends Response {
  ResponseInternal(HttpResponse inner) : super(inner);

  HttpResponse get inner => _inner;
}

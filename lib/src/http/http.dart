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
  HttpSession get session => _inner.session;
  List<Cookie> get cookies => _inner.cookies;

  Future<Map<String, String>> decodingBody() async {
    if (_body.isNotEmpty) {
      return _body;
    }
    var data = await _decoding();
    String json = data.containsKey('_value') ? data['_value']! : '';
    _body = json == '' ? {} : jsonDecode(json);
    return _body;
  }

  Future<Map<String, String>> _decoding() async {
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
  WebSocket? ws;
  RequestInternal(HttpRequest inner) : super(inner);
  String get baseUrl => _baseUrl;
  set baseUrl(value) => _baseUrl = value;
}

/// 对[HttpResponse]的封装
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

  Response sendStatus(int statusCode) {
    _inner.statusCode = statusCode;
    return this;
  }

  Response json(Map<String, dynamic> data) {
    _inner.write(jsonEncode(data));
    return this;
  }

  Response send(dynamic data) {
    if (data is List) {
      _inner.writeAll(data);
    } else {
      _inner.write(data);
    }
    return this;
  }

  Future<dynamic> close() => _inner.close();
}

class ResponseInternal extends Response {
  ResponseInternal(HttpResponse inner) : super(inner);

  HttpResponse get inner => _inner;
}

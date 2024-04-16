library http;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:summer/src/middleware/smart_balancer.dart';

part './request_handler.dart';
part './methods.dart';
part './server.dart';
part './final_handler.dart';
part './error/error.dart';

/// 对[HttpRequest]的封装
class Request {
  final Map<String, dynamic> _params = {};
  final HttpRequest _inner;
  dynamic _body;
  String _baseUrl = '';
  final Map _data = {};

  Request(this._inner);

  HttpHeaders get headers => _inner.headers;
  Uri get uri => _inner.uri;
  Uri get requestedUri => _inner.requestedUri;
  String get encoding => headers.contentType?.charset ?? '';
  String get method => _inner.method;
  String get protocolVersion => _inner.protocolVersion;
  Map<String, dynamic> get params => _params;
  Map<String, String> get query => uri.queryParameters;
  Future<dynamic> get body => decodingBody();
  HttpSession get session => _inner.session;
  List<Cookie> get cookies => _inner.cookies;
  Map get data => _data;

  Future<dynamic> decodingBody() async {
    if (_body != null) {
      return _body;
    }
    return await _decoding();
  }

  Future<dynamic> _decoding() async {
    var dataType = _dataType();
    if (dataType == 'json') {
      switch (encoding) {
        case 'utf-8':
          return await _utf8JsonDecoding();
      }
    } else if (dataType == 'x-www-form-urlencoded') {
      switch (encoding) {
        case 'utf-8':
          return await _utf8FormDecoding();
      }
    } else {
      return _bytesDecoding();
    }
  }

  String? _dataType() {
    return headers.contentType?.subType;
  }

  Future<Map<String, dynamic>> _utf8JsonDecoding() async {
    var json = await utf8.decoder.bind(_inner).join();
    return jsonDecode(json);
  }

  Future<Map<String, String>> _utf8FormDecoding() async {
    var query = await utf8.decoder.bind(_inner).join();
    return Uri.splitQueryString(query);
  }

  Future<List<int>> _bytesDecoding() async => await _inner
      .fold<List<int>>([], (prev, elements) => prev..addAll(elements));
}

class RequestInternal extends Request {
  HttpRequest get inner => _inner;
  WebSocket? ws;
  int? threadId;
  ThreadPool? threadPool;
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
  Future<dynamic> get done => _inner.done;

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

  Response jsonList(List<Map<String, dynamic>> data) {
    _inner.write(jsonEncode(data));
    return this;
  }

  Response send(dynamic data) {
    _inner.write(data);
    return this;
  }

  Response sendAll<T>(Iterable<T> data, [String separator = ""]) {
    _inner.writeAll(data, separator);
    return this;
  }

  Future<void> downloadFile(String path) async {
    Uri uri = Directory.current.uri.resolve(path);
    var file = File.fromUri(uri);
    if (await file.exists()) {
      var fileName = basename(file.path);
      var mimeType = mime(fileName) ?? 'application/octet-stream';
      _inner.headers
          .set('Content-Disposition', 'attachment; filename="$fileName"');
      _inner.headers.set('Content-Type', mimeType);
      _inner.writeAll(await file.readAsBytes());
    } else {
      throw FileSystemException('file dose not exists.', path);
    }
  }

  Future<dynamic> close() => _inner.close();
}

class ResponseInternal extends Response {
  ResponseInternal(HttpResponse inner) : super(inner);

  HttpResponse get inner => _inner;
}

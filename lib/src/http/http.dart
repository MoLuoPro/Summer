library http;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';

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

  /// 解析请求体,可解析表达以及json
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

/// 内部使用的[Request]
class RequestInternal extends Request {
  HttpRequest get inner => _inner;
  WebSocket? ws;
  RequestInternal(super.inner);
  String get baseUrl => _baseUrl;
  set baseUrl(value) => _baseUrl = value;
}

/// 对[HttpResponse]的封装
class Response {
  final HttpResponse _inner;

  Response(this._inner);

  int get statusCode => _inner.statusCode;
  set statusCode(value) => _inner.statusCode = value;
  HttpHeaders get headers => _inner.headers;
  List<Cookie> get cookies => _inner.cookies;
  Encoding get encoding => _inner.encoding;
  Future<dynamic> get done => _inner.done;

  Future<dynamic> redirect(Uri location,
          {int status = HttpStatus.movedTemporarily}) =>
      _inner.redirect(location, status: status);

  /// 对[Response]写入json
  Response json(Map<String, dynamic> data) {
    _inner.write(jsonEncode(data));
    return this;
  }

  /// 对[Response]写入json数组
  Response jsonList(List<Map<String, dynamic>> data) {
    _inner.write(jsonEncode(data));
    return this;
  }

  /// 写入任意对象
  Response send<T>(T data, [String separator = ""]) {
    if (data is Iterable) {
      _inner.writeAll(data, separator);
    } else {
      _inner.write(data);
    }
    return this;
  }

  /// 写入任意数组
  Response sendAll<T>(Iterable<T> data, [String separator = ""]) {
    _inner.writeAll(data, separator);
    return this;
  }

  /// 调用该方法后,前端执行下载
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

  /// 关闭响应
  Future<dynamic> close() => _inner.close();
}

/// 内部使用的[Response]
class ResponseInternal extends Response {
  ResponseInternal(super.inner);

  HttpResponse get inner => _inner;
}

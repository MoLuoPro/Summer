library http;

import 'dart:async';
import 'dart:io';

part './request_handler.dart';
part './http_method.dart';
part './server.dart';
part './final_handler.dart';

class HttpRequestWrapper {
  final Map<String, dynamic> _params = {};
  final HttpRequest _inner;

  HttpRequestWrapper(this._inner);

  HttpRequest get inner => _inner;
  Map<String, dynamic> get params => _params;
}

class HttpResponseWrapper {
  final HttpResponse _inner;

  HttpResponse get inner => _inner;

  HttpResponseWrapper(this._inner);
}

import 'dart:io';

import 'package:summer_mvc/src/http/http.dart';
import 'package:summer_mvc/src/router/router.dart';

class Application with Server, RequestHandler {
  final Map<String, dynamic> _settings = {};
  Router? _router;

  Application() {
    appHandle = handle;
  }

  set(String setting, dynamic val) {
    _settings[setting] = val;
  }

  use(String path, Function fn) {}

  handle(HttpRequest req, HttpResponse res, Function? next) {
    _router?.handle(req, res, next);
  }

  _lazyRouter() {
    _router ??= Router();
  }

  @override
  HttpMethod get(
      String path,
      void Function(HttpRequest req, HttpResponse res, Function? next)
          callback) {
    _lazyRouter();
    super.request(HttpMethod.httpGet, path, callback);
    var route = _router?.route(path);
    route?.request(HttpMethod.httpGet, callback);
    return this;
  }

  @override
  HttpMethod post(
      String path,
      void Function(HttpRequest req, HttpResponse res, Function? next)
          callback) {
    _lazyRouter();
    super.request(HttpMethod.httpPost, path, callback);
    _router?.route(path);
    var route = _router?.route(path);
    route?.request(HttpMethod.httpPost, callback);
    return this;
  }

  HttpMethod all(
      String path,
      void Function(HttpRequest req, HttpResponse res, Function? next)
          callback) {
    _lazyRouter();
    for (var method in HttpMethod.methods) {
      super.request(method, path, callback);
      var route = _router?.route(path);
      route?.request(method, callback);
    }
    return this;
  }
}

Application createApplication() {
  return Application();
}

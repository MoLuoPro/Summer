import 'dart:async';
import 'dart:io';

import 'package:sumcat/src/http/http.dart';
import 'package:sumcat/src/router/router.dart';

class Application with Server, RequestHandler {
  final Map<String, dynamic> _settings = {};
  Router? _router;

  @override
  Future<void> listen(int port) {
    request(handle);
    return super.listen(port);
  }

  Application set(String setting, dynamic val) {
    _settings[setting] = val;
    return this;
  }

  Application use(String path, Function fn) {
    return this;
  }

  void handle(
    HttpRequest req,
    HttpResponse res, [
    void Function([String? err])? done,
  ]) {
    _router?.handle(req, res, done);
  }

  void _lazyRouter() {
    _router ??= Router();
  }

  @override
  HttpMethod get(
      String path,
      List<
              void Function(
                  HttpRequest req, HttpResponse res, Completer<String?> next)>
          callbacks) {
    _lazyRouter();
    var route = _router?.route(path);
    for (var cb in callbacks) {
      route?.request(HttpMethod.httpGet, cb);
    }
    return this;
  }

  @override
  HttpMethod post(
      String path,
      List<
              void Function(
                  HttpRequest req, HttpResponse res, Completer<String?> next)>
          callbacks) {
    _lazyRouter();
    var route = _router?.route(path);
    for (var cb in callbacks) {
      route?.request(HttpMethod.httpPost, cb);
    }
    return this;
  }

  HttpMethod all(
      String path,
      List<
              void Function(
                  HttpRequest req, HttpResponse res, Completer<String?> next)>
          callbacks) {
    _lazyRouter();
    for (var method in HttpMethod.methods) {
      var route = _router?.route(path);
      for (var cb in callbacks) {
        route?.request(method, cb);
      }
    }
    return this;
  }
}

Application createApplication() {
  return Application();
}

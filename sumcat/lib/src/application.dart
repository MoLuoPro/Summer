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

  Application use({String path = '/', required List<HttpHandler> fns}) {
    _lazyRouter();
    _router?.use(path: path, fns: fns);
    return this;
  }

  Application useRouter({String path = '/', required Router router}) {
    _lazyRouter();
    _router?.useRouter(path: path, router: router);
    return this;
  }

  Application params(
      List<String> names,
      void Function(HttpRequestWrapper req, HttpResponseWrapper res,
              Completer<String?> next, dynamic, String name)
          fn) {
    _lazyRouter();
    for (var name in names) {
      param(name, fn);
    }
    return this;
  }

  Application param(
      String name,
      void Function(HttpRequestWrapper req, HttpResponseWrapper res,
              Completer<String?> next, dynamic, String name)
          fn) {
    _lazyRouter();
    _router?.param(name, fn);
    return this;
  }

  FutureOr<void> handle(
    HttpRequestWrapper req,
    HttpResponseWrapper res, [
    void Function(HttpRequestWrapper req, HttpResponseWrapper res, String? err)?
        done,
  ]) async {
    var handler = done ??
        (WebSocketTransformer.isUpgradeRequest(req.inner)
            ? webSocketFinalHandler
            : httpFinalHandler);
    _lazyRouter();
    await _router?.handle(req, res, handler);
  }

  void _lazyRouter() {
    _router ??= Router();
  }

  @override
  RequestHandler get(String path, List<HttpHandler> callbacks) {
    _lazyRouter();
    var route = _router?.route(path);
    for (var cb in callbacks) {
      route?.request(HttpMethod.httpGet, cb);
    }
    return this;
  }

  @override
  RequestHandler post(String path, List<HttpHandler> callbacks) {
    _lazyRouter();
    var route = _router?.route(path);
    for (var cb in callbacks) {
      route?.request(HttpMethod.httpPost, cb);
    }
    return this;
  }

  RequestHandler all(String path, List<HttpHandler> callbacks) {
    _lazyRouter();
    for (var method in HttpMethod.methods) {
      var route = _router?.route(path);
      for (var cb in callbacks) {
        route?.request(method, cb);
      }
    }
    return this;
  }

  @override
  RequestHandler ws(String path, List<WebSocketHandler> callbacks) {
    _lazyRouter();
    var route = _router?.route(path);
    for (var cb in callbacks) {
      route?.request(WebSocketMethod.webSocket, cb);
    }
    return this;
  }

  // @override
  // RequestHandler tcp(String path, List<SocketHandler> callbacks) {
  //   _lazyRouter();
  //   var route = _router?.route(path);
  //   for (var cb in callbacks) {
  //     route?.request(TCPMethod.tcpMethod, cb);
  //   }
  //   return this;
  // }

  // @override
  // RequestHandler udp(String path, List<SocketHandler> callbacks) {
  //   _lazyRouter();
  //   var route = _router?.route(path);
  //   for (var cb in callbacks) {
  //     route?.request(UDPMethod.udpMethod, cb);
  //   }
  //   return this;
  // }
}

Application createApplication() {
  return Application();
}

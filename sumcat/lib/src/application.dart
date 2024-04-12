import 'dart:async';
import 'dart:io';

import 'package:sumcat/src/http/http.dart';
import 'package:sumcat/src/router/router.dart';

class Application with Server, RequestHandler {
  final Map<String, dynamic> _settings = {};
  WebSocketRouter? _webSocketRouter;
  HttpRouter? _httpRouter;
  TCPRouter? _tcpRouter;
  UDPRouter? _udpRouter;

  @override
  Future<void> listen({int? httpPort, int? tcpPort, int? udpPort}) {
    if (httpPort != null) {
      request(_httpHandle, _webSocketHandle);
    }
    if (tcpPort != null) {
      tcpRequest(_tcpHandle);
    }
    if (udpPort != null) {
      udpRequest(_udpHandle);
    }
    return super.listen(httpPort: httpPort, tcpPort: tcpPort, udpPort: udpPort);
  }

  Application set(String setting, dynamic val) {
    _settings[setting] = val;
    return this;
  }

  Application use({String path = '/', required List<HttpHandler> fns}) {
    use() async {
      await _lazyRouter();
      _httpRouter?.use(path: path, fns: fns);
    }

    use();
    return this;
  }

  Application useHttpRouter({String path = '/', required HttpRouter router}) {
    useRouter() async {
      await _lazyRouter();
      _httpRouter?.useRouter(path: path, router: router);
    }

    useRouter();
    return this;
  }

  Application useWebSocketRouter(
      {String path = '/', required WebSocketRouter router}) {
    useRouter() async {
      await _lazyRouter();
      _webSocketRouter?.useRouter(path: path, router: router);
    }

    useRouter();
    return this;
  }

  void useTCPRouter(TCPRouter router) {
    useRouter() async {
      await _lazyRouter();
      _tcpRouter?.useRouter(path: '/', router: router);
    }

    useRouter();
  }

  void useUDPRouter(UDPRouter router) {
    useRouter() async {
      await _lazyRouter();
      _udpRouter?.useRouter(path: '/', router: router);
    }

    useRouter();
  }

  Application params(
      List<String> names,
      void Function(HttpRequestWrapper req, HttpResponseWrapper res,
              Completer<String?> next, dynamic, String name)
          fn) {
    params() async {
      await _lazyRouter();
      for (var name in names) {
        param(name, fn);
      }
    }

    params();
    return this;
  }

  Application param(
      String name,
      void Function(HttpRequestWrapper req, HttpResponseWrapper res,
              Completer<String?> next, dynamic, String name)
          fn) {
    param() async {
      await _lazyRouter();
      _httpRouter?.param(name, fn);
    }

    param();
    return this;
  }

  FutureOr<void> _httpHandle(
      HttpRequestWrapper req,
      HttpResponseWrapper res,
      void Function(
              HttpRequestWrapper req, HttpResponseWrapper res, String? err)?
          done) async {
    var handler = done ?? httpFinalHandler;
    await _lazyRouter();
    await _httpRouter?.handle([req, res], handler);
  }

  FutureOr<void> _webSocketHandle(
      HttpRequestWrapper req,
      WebSocket ws,
      void Function(HttpRequestWrapper req, WebSocket ws, String? err)?
          done) async {
    var handler = done ?? webSocketFinalHandler;
    await _lazyRouter();
    await _webSocketRouter?.handle([req, ws], handler);
  }

  FutureOr<void> _tcpHandle(
      Socket client, void Function(Socket client, String? err)? done) async {
    await _lazyRouter();
    await _tcpRouter?.handle([client], null);
  }

  FutureOr<void> _udpHandle(RawDatagramSocket client,
      void Function(RawDatagramSocket client, String? err)? done) async {
    await _lazyRouter();
    await _udpRouter?.handle([client], null);
  }

  Future<void> _lazyRouter() async {
    if (await isHttpServerConnected()) {
      _httpRouter ??= HttpRouter();
      _webSocketRouter ??= WebSocketRouter();
    }
    if (await isTCPServerConnected()) {
      _tcpRouter ??= TCPRouter();
    }
    if (await isUDPServerConnected()) {
      _udpRouter ??= UDPRouter();
    }
  }

  @override
  RequestHandler get(String path, List<HttpHandler> callbacks) {
    void get() async {
      await _lazyRouter();
      var route = _httpRouter?.route(path);
      for (var cb in callbacks) {
        route?.request(HttpMethod.httpGet, cb);
      }
    }

    get();
    return this;
  }

  @override
  RequestHandler post(String path, List<HttpHandler> callbacks) {
    post() async {
      await _lazyRouter();
      var route = _httpRouter?.route(path);
      for (var cb in callbacks) {
        route?.request(HttpMethod.httpPost, cb);
      }
    }

    post();
    return this;
  }

  RequestHandler all(String path, List<HttpHandler> callbacks) {
    void all() async {
      await _lazyRouter();
      for (var method in HttpMethod.methods) {
        var route = _httpRouter?.route(path);
        for (var cb in callbacks) {
          route?.request(method, cb);
        }
      }
    }

    all();
    return this;
  }

  @override
  WebSocketMethod ws(String path, List<WebSocketHandler> callbacks) {
    void ws() async {
      await _lazyRouter();
      var route = _webSocketRouter?.route(path);
      for (var cb in callbacks) {
        route?.request(WebSocketMethod.name, cb);
      }
    }

    ws();
    return this;
  }

  @override
  TCPMethod tcp(List<TCPSocketHandler> callbacks) {
    void tcp() async {
      await _lazyRouter();
      var route = _tcpRouter?.route('/');
      for (var cb in callbacks) {
        route?.request(TCPMethod.name, cb);
      }
    }

    tcp();
    return this;
  }

  @override
  UDPMethod udp(List<UDPSocketHandler> callbacks) {
    udp() async {
      await _lazyRouter();
      var route = _udpRouter?.route('');
      for (var cb in callbacks) {
        route?.request(UDPMethod.name, cb);
      }
    }

    udp();
    return this;
  }
}

Application createApplication() {
  return Application();
}

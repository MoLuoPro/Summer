import 'dart:async';
import 'dart:io';

import 'package:summer/src/router/router.dart';

import 'http/http.dart';

class Application with Server, RequestHandler {
  // final Map<String, dynamic> _settings = {};
  WebSocketRouterInternal? _webSocketRouter;
  HttpRouterInternal? _httpRouter;
  TCPRouterInternal? _tcpRouter;
  UDPRouterInternal? _udpRouter;

  /// 启动并监听端口
  /// [httpPort]监听http请求
  /// [tcpPort]和[udpPort]分别监听tcp和udp
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

  // Application set(String setting, dynamic val) {
  //   _settings[setting] = val;
  //   return this;
  // }

  /// 注册中间件
  Application use({String path = '/', required List<HttpHandler> fns}) {
    use() async {
      await _lazyRouter();
      _httpRouter?.use(path: path, fns: fns);
    }

    use();
    return this;
  }

  /// 注册[HttpRouter]
  Application useHttpRouter({String path = '/', required HttpRouter router}) {
    useRouter() async {
      await _lazyRouter();
      _httpRouter?.useRouter(path: path, router: router);
    }

    useRouter();
    return this;
  }

  /// 注册[WebSocketRouter]
  Application useWebSocketRouter(
      {String path = '/', required WebSocketRouter router}) {
    useRouter() async {
      await _lazyRouter();
      _webSocketRouter?.useRouter(path: path, router: router);
    }

    useRouter();
    return this;
  }

  /// 注册[TCPRouter]
  void useTCPRouter(TCPRouter router) {
    useRouter() async {
      await _lazyRouter();
      _tcpRouter?.useRouter(path: '/', router: router);
    }

    useRouter();
  }

  /// 注册[UDPRouter]
  void useUDPRouter(UDPRouter router) {
    useRouter() async {
      await _lazyRouter();
      _udpRouter?.useRouter(path: '/', router: router);
    }

    useRouter();
  }

  /// 参数处理器,在处理请求之前调用,可输入多个参数名称
  Application params(List<String> names, Function fn) {
    params() async {
      await _lazyRouter();
      for (var name in names) {
        param(name, fn);
      }
    }

    params();
    return this;
  }

  /// 参数处理器,在处理请求之前调用
  Application param(String name, Function fn) {
    param() async {
      await _lazyRouter();
      _httpRouter?.param(name, fn);
    }

    param();
    return this;
  }

  FutureOr<void> _httpHandle(Request req, Response res,
      void Function(Request req, Response res, String? err)? done) async {
    var handler = done ?? httpFinalHandler;
    await _lazyRouter();
    await _httpRouter?.handle([req, res], handler);
  }

  FutureOr<void> _webSocketHandle(Request req, WebSocket ws,
      void Function(Request req, WebSocket ws, String? err)? done) async {
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
      _httpRouter ??= HttpRouterInternal();
      _webSocketRouter ??= WebSocketRouterInternal();
    }
    if (await isTCPServerConnected()) {
      _tcpRouter ??= TCPRouterInternal();
    }
    if (await isUDPServerConnected()) {
      _udpRouter ??= UDPRouterInternal();
    }
  }

  Future<void> _checkServerConnection() async {
    if (!await isHttpServerConnected()) {
      throw Exception('Server connection failure');
    }
  }

  Future<void> _checkTCPConnection() async {
    if (!await isHttpServerConnected()) {
      throw Exception('TCP connection failure');
    }
  }

  Future<void> _checkUDPConnection() async {
    if (!await isHttpServerConnected()) {
      throw Exception('UDP connection failure');
    }
  }

  /// [get]请求
  @override
  Application get(String path, List<HttpHandler> callbacks) {
    void get() async {
      await _lazyRouter();
      await _checkServerConnection();
      var route = _httpRouter?.route(path);
      for (var cb in callbacks) {
        route?.request(HttpMethod.httpGet, cb);
      }
    }

    get();
    return this;
  }

  /// [post]请求
  @override
  Application post(String path, List<HttpHandler> callbacks) {
    void post() async {
      await _lazyRouter();
      await _checkServerConnection();
      var route = _httpRouter?.route(path);
      for (var cb in callbacks) {
        route?.request(HttpMethod.httpPost, cb);
      }
    }

    post();
    return this;
  }

  /// [delete]请求
  @override
  Application delete(String path, List<HttpHandler> callbacks) {
    void delete() async {
      await _lazyRouter();
      await _checkServerConnection();
      var route = _httpRouter?.route(path);
      for (var cb in callbacks) {
        route?.request(HttpMethod.httpDelete, cb);
      }
    }

    delete();
    return this;
  }

  /// [head]请求
  @override
  Application head(String path, List<HttpHandler> callbacks) {
    void head() async {
      await _lazyRouter();
      await _checkServerConnection();
      var route = _httpRouter?.route(path);
      for (var cb in callbacks) {
        route?.request(HttpMethod.httpHead, cb);
      }
    }

    head();
    return this;
  }

  /// [options]请求
  @override
  Application options(String path, List<HttpHandler> callbacks) {
    void options() async {
      await _lazyRouter();
      await _checkServerConnection();
      var route = _httpRouter?.route(path);
      for (var cb in callbacks) {
        route?.request(HttpMethod.httpOptions, cb);
      }
    }

    options();
    return this;
  }

  /// [patch]请求
  @override
  Application patch(String path, List<HttpHandler> callbacks) {
    void patch() async {
      await _lazyRouter();
      await _checkServerConnection();
      var route = _httpRouter?.route(path);
      for (var cb in callbacks) {
        route?.request(HttpMethod.httpPatch, cb);
      }
    }

    patch();
    return this;
  }

  /// [put]请求
  @override
  Application put(String path, List<HttpHandler> callbacks) {
    void put() async {
      await _lazyRouter();
      await _checkServerConnection();
      var route = _httpRouter?.route(path);
      for (var cb in callbacks) {
        route?.request(HttpMethod.httpPut, cb);
      }
    }

    put();
    return this;
  }

  /// 所有请求
  Application all(String path, List<HttpHandler> callbacks) {
    void all() async {
      await _lazyRouter();
      await _checkServerConnection();
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

  /// webSocket
  @override
  WebSocketMethod ws(String path, List<WebSocketHandler> callbacks) {
    void ws() async {
      await _lazyRouter();
      await _checkServerConnection();
      var route = _webSocketRouter?.route(path);
      for (var cb in callbacks) {
        route?.request(WebSocketMethod.name, cb);
      }
    }

    ws();
    return this;
  }

  /// tcp
  @override
  void tcp(TCPSocketHandler callback) {
    void tcp() async {
      await _lazyRouter();
      await _checkTCPConnection();
      var route = _tcpRouter?.route('/');
      route?.request(TCPMethod.name, callback);
    }

    tcp();
  }

  /// udp
  @override
  void udp(UDPSocketHandler callback) {
    udp() async {
      await _lazyRouter();
      await _checkUDPConnection();
      var route = _udpRouter?.route('');
      route?.request(UDPMethod.name, callback);
    }

    udp();
  }
}

/// 创建应用
Application createApp() {
  return Application();
}

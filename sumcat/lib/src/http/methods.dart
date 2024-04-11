part of http;

typedef HttpHandler = FutureOr<void> Function(
    HttpRequestWrapper req, HttpResponseWrapper res, Completer<String?> next);
typedef WebSocketHandler = FutureOr<void> Function(
    HttpRequestWrapper req, WebSocket ws);
typedef HttpErrorHandler = FutureOr<void> Function(String? err,
    HttpRequestWrapper req, HttpResponseWrapper res, Completer<String?> next);
typedef WebSocketErrorHandler = FutureOr<void> Function(
    String? err, HttpRequestWrapper req, WebSocket ws);
typedef SocketHandler = FutureOr<void> Function(ServerSocket socket);
typedef SocketErrorHandler = FutureOr<void> Function(
    String? err, ServerSocket socket);

abstract class HttpMethod {
  static const String httpAll = 'ALL';
  static const String httpGet = 'GET';
  static const String httpPost = 'POST';
  static const List<String> methods = [httpGet, httpPost];

  HttpMethod get(String uri, List<HttpHandler> callbacks);
  HttpMethod post(String uri, List<HttpHandler> callbacks);
}

abstract class WebSocketMethod {
  static const String webSocket = 'WEB_SOCKET';
  WebSocketMethod ws(String uri, List<WebSocketHandler> callbacks);
}

abstract class TCPMethod {
  static const String tcpMethod = 'TCP';
  TCPMethod tcp(String uri, List<SocketHandler> callbacks);
}

abstract class UDPMethod {
  static const String udpMethod = 'UDP';
  TCPMethod udp(String uri, List<SocketHandler> callbacks);
}

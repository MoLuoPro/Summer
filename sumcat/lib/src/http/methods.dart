part of http;

typedef HttpHandler = FutureOr<void> Function(
    HttpRequestWrapper req, HttpResponseWrapper res, Completer<String?> next);
typedef HttpErrorHandler = FutureOr<void> Function(String? err,
    HttpRequestWrapper req, HttpResponseWrapper res, Completer<String?> next);
typedef HttpFinalHandle = void Function(
    HttpRequestWrapper req, HttpResponseWrapper res, String? err);
typedef HttpRequestHandle = FutureOr<void> Function(
    HttpRequestWrapper req,
    HttpResponseWrapper res,
    void Function(HttpRequestWrapper req, HttpResponseWrapper res, String? err)?
        done);
typedef WebSocketHandler = FutureOr<void> Function(
    HttpRequestWrapper req, WebSocket ws, Completer<String?> next);
typedef WebSocketErrorHandler = FutureOr<void> Function(
    String? err, HttpRequestWrapper req, WebSocket ws, Completer<String?> next);
typedef WebSocketFinalHandle = void Function(
    HttpRequestWrapper req, WebSocket ws, String? err);
typedef WebSocketRequestHandle = FutureOr<void> Function(
    HttpRequestWrapper req,
    WebSocket ws,
    void Function(HttpRequestWrapper req, WebSocket ws, String? err)? done);
typedef TCPSocketHandler = FutureOr<void> Function(
    Socket socket, Completer<String?> next);
typedef TCPSocketErrorHandler = FutureOr<void> Function(
    String? err, Socket socket, Completer<String?> next);
typedef TCPSocketFinalHandle = void Function(Socket client, String? err);
typedef UDPSocketHandler = FutureOr<void> Function(
    RawDatagramSocket client, Completer<String?> next);
typedef UDPSocketErrorHandler = FutureOr<void> Function(
    String? err, RawDatagramSocket client, Completer<String?> next);
typedef UDPSocketFinalHandle = void Function(
    RawDatagramSocket client, String? err);

abstract class HttpMethod {
  static const String httpAll = 'ALL';
  static const String httpGet = 'GET';
  static const String httpPost = 'POST';
  static const String httpPut = 'PUT';
  static const String httpPatch = 'PATCH';
  static const String httpDelete = 'DELETE';
  static const String httpHead = 'HEAD';
  static const String httpOptions = 'OPTIONS';
  static const List<String> methods = [
    httpGet,
    httpPost,
    httpPut,
    httpPatch,
    httpDelete,
    httpHead,
    httpOptions
  ];

  HttpMethod get(String uri, List<Function> callbacks);
  HttpMethod post(String uri, List<Function> callbacks);
  HttpMethod put(String uri, List<Function> callbacks);
  HttpMethod patch(String uri, List<Function> callbacks);
  HttpMethod delete(String uri, List<Function> callbacks);
  HttpMethod head(String uri, List<Function> callbacks);
  HttpMethod options(String uri, List<Function> callbacks);
}

abstract class WebSocketMethod {
  static const String name = 'WEB_SOCKET';
  WebSocketMethod ws(String uri, List<Function> callbacks);
}

abstract class TCPMethod {
  static const String name = 'TCP';
  void tcp(List<Function> callbacks);
}

abstract class UDPMethod {
  static const String name = 'UDP';
  void udp(List<Function> callbacks);
}

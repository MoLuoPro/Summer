part of http;

typedef HttpHandler = FutureOr<void> Function(
    Request req, Response res, Completer<String?> next);
typedef HttpSimpleHandler = FutureOr<void> Function(Request req, Response res);
typedef HttpErrorHandler = FutureOr<void> Function(
    String? err, Request req, Response res, Completer<String?> next);
typedef HttpErrorSimpleHandler = FutureOr<void> Function(
    String? err, Request req, Response res);
typedef HttpFinalHandle = void Function(Request req, Response res, String? err);
typedef HttpRequestHandle = FutureOr<void> Function(Request req, Response res,
    void Function(Request req, Response res, String? err)? done);

typedef WebSocketHandler = FutureOr<void> Function(
    Request req, WebSocket ws, Completer<String?> next);
typedef WebSocketSimpleHandler = FutureOr<void> Function(
    Request req, WebSocket ws);
typedef WebSocketErrorHandler = FutureOr<void> Function(
    String? err, Request req, WebSocket ws, Completer<String?> next);
typedef WebSocketErrorSimpleHandler = FutureOr<void> Function(
    String? err, Request req, WebSocket ws);
typedef WebSocketFinalHandle = void Function(
    Request req, WebSocket ws, String? err);
typedef WebSocketRequestHandle = FutureOr<void> Function(Request req,
    WebSocket ws, void Function(Request req, WebSocket ws, String? err)? done);

typedef TCPSocketHandler = FutureOr<void> Function(
    Socket socket, Completer<String?> next);
typedef TCPSocketSimpleHandler = FutureOr<void> Function(Socket socket);
typedef TCPSocketErrorHandler = FutureOr<void> Function(
    String? err, Socket socket, Completer<String?> next);
typedef TCPSocketErrorSimpeHandler = FutureOr<void> Function(
    String? err, Socket socket);
typedef TCPSocketFinalHandle = void Function(Socket client, String? err);

typedef UDPSocketHandler = FutureOr<void> Function(
    RawDatagramSocket client, Completer<String?> next);
typedef UDPSocketSimpleHandler = FutureOr<void> Function(
    RawDatagramSocket client, Completer<String?> next);
typedef UDPSocketErrorHandler = FutureOr<void> Function(
    String? err, RawDatagramSocket client, Completer<String?> next);
typedef UDPSocketErrorSimpleHandler = FutureOr<void> Function(
    String? err, RawDatagramSocket client);
typedef UDPSocketFinalHandle = void Function(
    RawDatagramSocket client, String? err);

typedef ParamHandler = FutureOr<void> Function(Request req, Response res,
    String val, String name, Completer<String?> next);
typedef ParamSimpleHandler = FutureOr<void> Function(
    Request req, Response res, String val, String name);

typedef WebSocketParamHandler = FutureOr<void> Function(Request req,
    WebSocket ws, String val, String name, Completer<String?> next);
typedef WebSocketParamSimpleHandler = FutureOr<void> Function(
    Request req, WebSocket ws, String val, String name);

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

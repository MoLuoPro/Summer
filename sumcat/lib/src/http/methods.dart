part of http;

typedef HttpHandler = FutureOr<void> Function(
    HttpRequestWrapper req, HttpResponseWrapper res, Completer<String?> next);
typedef WebSocketHandler = FutureOr<void> Function(
    HttpRequestWrapper req, WebSocket ws);
typedef HttpErrorHandler = FutureOr<void> Function(String? err,
    HttpRequestWrapper req, HttpResponseWrapper res, Completer<String?> next);
typedef WebSocketErrorHandler = FutureOr<void> Function(
    String? err, HttpRequestWrapper req, WebSocket ws);

abstract class HttpMethod {
  static const String httpAll = 'ALL';
  static const String httpGet = 'GET';
  static const String httpPost = 'POST';
  static const List<String> methods = [httpGet, httpPost];

  HttpMethod get(String uri, List<HttpHandler> callbacks);
  HttpMethod post(String uri, List<HttpHandler> callbacks);
}

abstract class WebSocketMethod {
  static const String webSocket = 'webSocket';
  WebSocketMethod ws(String uri, List<WebSocketHandler> callbacks);
}

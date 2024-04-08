part of http;

abstract class HttpMethod {
  static const String httpAll = 'ALL';
  static const String httpGet = 'GET';
  static const String httpPost = 'POST';
  static const List<String> methods = [httpGet, httpPost];

  HttpMethod request(
      void Function(HttpRequest req, HttpResponse res,
              void Function(HttpRequest, HttpResponse, String?)? done)
          appHandle);
  HttpMethod get(
      String uri,
      List<
              void Function(
                  HttpRequest req, HttpResponse res, Completer<String?> next)>
          callbacks);
  HttpMethod post(
      String uri,
      List<
              void Function(
                  HttpRequest req, HttpResponse res, Completer<String?> next)>
          callbacks);
}

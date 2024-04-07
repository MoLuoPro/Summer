part of http;

abstract class HttpMethod {
  static const String httpAll = 'ALL';
  static const String httpGet = 'GET';
  static const String httpPost = 'POST';
  static const List<String> methods = [httpGet, httpPost];

  HttpMethod request(String method, String uri,
      void Function(HttpRequest req, HttpResponse res, Function? next) next);
  HttpMethod get(String uri,
      void Function(HttpRequest req, HttpResponse res, Function? next) next);
  HttpMethod post(String uri,
      void Function(HttpRequest req, HttpResponse res, Function? next) next);
}

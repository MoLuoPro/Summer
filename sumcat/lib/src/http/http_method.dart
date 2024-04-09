part of http;

abstract class HttpMethod {
  static const String httpAll = 'ALL';
  static const String httpGet = 'GET';
  static const String httpPost = 'POST';
  static const List<String> methods = [httpGet, httpPost];

  HttpMethod request(
      void Function(
              HttpRequestWrapper req,
              HttpResponseWrapper res,
              void Function(HttpRequestWrapper, HttpResponseWrapper, String?)?
                  done)
          appHandle);
  HttpMethod get(
      String uri,
      List<
              void Function(HttpRequestWrapper req, HttpResponseWrapper res,
                  Completer<String?> next)>
          callbacks);
  HttpMethod post(
      String uri,
      List<
              void Function(HttpRequestWrapper req, HttpResponseWrapper res,
                  Completer<String?> next)>
          callbacks);
}

part of http;

mixin RequestHandler on Server implements HttpMethod, WebSocketMethod {
  Future<void> _request(
      FutureOr<void> Function(
              HttpRequestWrapper req,
              HttpResponseWrapper res,
              void Function(HttpRequestWrapper req, HttpResponseWrapper res,
                      String? err)?
                  done)
          appHandle) async {
    await _listened.future;
    await for (HttpRequest req in _server) {
      await appHandle(HttpRequestWrapperInternal(req),
          HttpResponseWrapperInternal(req.response), null);
    }
  }

  HttpMethod request(
      FutureOr<void> Function(
              HttpRequestWrapper req,
              HttpResponseWrapper res,
              void Function(HttpRequestWrapper req, HttpResponseWrapper res,
                      String? err)?
                  done)
          appHandle) {
    _request(appHandle);
    return this;
  }
}

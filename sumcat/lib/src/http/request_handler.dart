part of http;

mixin RequestHandler on Server implements HttpMethod {
  Future<void> _request(
      void Function(
              HttpRequestWrapper req,
              HttpResponseWrapper res,
              void Function(HttpRequestWrapper, HttpResponseWrapper, String?)?
                  done)
          appHandle) async {
    await _listened.future;
    server.forEach((req) async {
      appHandle(HttpRequestWrapperInternal(req),
          HttpResponseWrapperInternal(req.response), null);
    });
  }

  HttpMethod request(
      void Function(
              HttpRequestWrapper req,
              HttpResponseWrapper res,
              void Function(HttpRequestWrapper, HttpResponseWrapper, String?)?
                  done)
          appHandle) {
    _request(appHandle);
    return this;
  }
}

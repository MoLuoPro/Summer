part of http;

mixin RequestHandler on Server implements HttpMethod {
  Future<void> _request(
      void Function(HttpRequest req, HttpResponse res,
              void Function(HttpRequest, HttpResponse, String?)? done)
          appHandle) async {
    await _listened.future;
    server.forEach((req) async {
      appHandle(req, req.response, null);
    });
  }

  @override
  HttpMethod request(
      void Function(HttpRequest req, HttpResponse res,
              void Function(HttpRequest, HttpResponse, String?)? done)
          appHandle) {
    _request(appHandle);
    return this;
  }
}

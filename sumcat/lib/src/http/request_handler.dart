part of http;

mixin RequestHandler on Server implements HttpMethod {
  Future<void> _request(
      void Function(HttpRequest req, HttpResponse res,
              void Function([String? err])? done)
          appHandle) async {
    await _listened.future;
    server.forEach((req) async {
      appHandle(req, req.response, null);
      await req.response.close();
    });
  }

  @override
  HttpMethod request(
      void Function(HttpRequest req, HttpResponse res,
              void Function([String? err])? done)
          appHandle) {
    _request(appHandle);
    return this;
  }
}

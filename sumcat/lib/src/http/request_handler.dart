part of http;

mixin RequestHandler on Server implements HttpMethod {
  Future<void> _request(String type, String path, Function callback) async {
    await _listened.future;
    server.forEach((req) async {
      appHandle(req, req.response, callback);
      // if (req.method == type || type == HttpMethod.httpAll) {
      //   if (req.uri.toString() == path) {
      //     callback.call(req, req.response);
      //   }
      // } else {
      //   req.response.statusCode = HttpStatus.methodNotAllowed;
      // }
      await req.response.close();
    });
  }

  @override
  HttpMethod request(
      String type,
      String path,
      void Function(HttpRequest req, HttpResponse res, Function? next)
          callback) {
    _request(type, path, callback);
    return this;
  }
}

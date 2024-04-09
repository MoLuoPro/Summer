part of http;

Future<void> finalHandler(
    HttpRequestWrapper req, HttpResponseWrapper res, String? err) async {
  var code = res._inner.statusCode;
  //res.writeln('status code: $code');
  await res.inner.close();
}

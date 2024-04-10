part of http;

Future<void> httpFinalHandler(
    HttpRequestWrapper req, HttpResponseWrapper res, String? err) async {
  var code = res._inner.statusCode;
  //res.writeln('status code: $code');
  await res.inner.close();
}

Future<void> webSocketFinalHandler(
    HttpRequestWrapper req, HttpResponseWrapper res, String? err) async {
  var internalReq = req as HttpRequestWrapperInternal;
  var code = res._inner.statusCode;
}

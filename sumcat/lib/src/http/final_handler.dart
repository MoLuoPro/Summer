part of http;

Future<void> httpFinalHandler(
    HttpRequestWrapper req, HttpResponseWrapper res, String? err) async {
  var code = res._inner.statusCode;
  if (code >= 400) {
    res.inner.writeln('status code: $code');
    res.inner.writeln('err: $err');
  }
  await res.inner.close();
}

Future<void> webSocketFinalHandler(
    HttpRequestWrapper req, HttpResponseWrapper res, String? err) async {
  var internalReq = req as HttpRequestWrapperInternal;
  var code = res._inner.statusCode;
  // var _httpRequest = (req as HttpRequestWrapperInternal);
  // await _httpRequest.ws?.close();
}

part of http;

Future<void> finalHandler(
    HttpRequestWrapper req, HttpResponse res, String? err) async {
  var code = res.statusCode;
  //res.writeln('status code: $code');
  await res.close();
}

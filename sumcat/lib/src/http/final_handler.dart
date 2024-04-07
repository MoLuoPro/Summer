part of http;

Future<void> finalHandler(HttpRequest req, HttpResponse res) async {
  var code = res.statusCode;
  res.write('status code: $code');
  await res.close();
}

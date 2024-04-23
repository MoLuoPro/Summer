part of 'http.dart';

Future<void> httpFinalHandler(Request req, Response res, String? err) async {
  var code = res._inner.statusCode;
  if (code >= 400) {
    res._inner.writeln('status code: $code');
    res._inner.writeln('err: $err');
  }
  await res._inner.close();
}

Future<void> webSocketFinalHandler(
    Request req, WebSocket ws, String? err) async {
  var res = req._inner.response;
  var code = res.statusCode;
  if (code >= 400) {
    res.writeln('status code: $code');
    res.writeln('err: $err');
    await res.close();
  }
}

FutureOr<void> tcpFinalHandler(Socket client, String? err) {}

FutureOr<void> udpFinalHandler(RawDatagramSocket client, String? err) {}

part of http;

mixin Server {
  late final HttpServer server;
  late final Completer _listened = Completer();
  late final void Function(HttpRequest req, HttpResponse res, Function callback)
      appHandle;

  Future<void> listen(int port) async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _listened.complete();
  }

  Future<void> quit() async {
    ProcessSignal.sigint.watch().listen((event) async {
      await server.close();
      exit(0);
    });
  }
}

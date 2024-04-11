part of http;

mixin Server {
  late final HttpServer _server;
  // late final ServerSocket _socket;
  final Completer _listened = Completer();

  Future<void> listen(int port) async {
    // _socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _listened.complete();
  }

  Future<void> quit() async {
    ProcessSignal.sigint.watch().listen((event) async {
      await _server.close();
      exit(0);
    });
  }
}

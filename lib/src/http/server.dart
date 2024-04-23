part of 'http.dart';

mixin Server {
  HttpServer? _server;
  ServerSocket? _tcp;
  RawDatagramSocket? _udp;
  final Completer _listened = Completer();

  Future<void> listen({int? httpPort, int? tcpPort, int? udpPort}) async {
    if (httpPort != null) {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, httpPort);
    }
    if (tcpPort != null) {
      _tcp = await ServerSocket.bind(InternetAddress.loopbackIPv4, tcpPort);
    }
    if (udpPort != null) {
      _udp =
          await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, udpPort);
    }
    _listened.complete();
  }

  Future<void> quit() async {
    ProcessSignal.sigint.watch().listen((event) async {
      await _server?.close();
      exit(0);
    });
  }

  /// 检查[HttpServer]是否连接
  Future<bool> isHttpServerConnected() async {
    await _listened.future;
    return _server != null;
  }

  /// 检查[ServerSocket]是否连接
  Future<bool> isTCPServerConnected() async {
    await _listened.future;
    return _tcp != null;
  }

  /// 检查[RawDatagramSocket]是否连接
  Future<bool> isUDPServerConnected() async {
    await _listened.future;
    return _udp != null;
  }
}

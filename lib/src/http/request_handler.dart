part of http;

///监听[Server]的请求
mixin RequestHandler on Server
    implements HttpMethod, WebSocketMethod, TCPMethod, UDPMethod {
  void request(HttpRequestHandle httpHandle, WebSocketRequestHandle wsHandle) {
    request() async {
      await _listened.future;
      await for (HttpRequest req in _server!) {
        if (WebSocketTransformer.isUpgradeRequest(req)) {
          var socket = await WebSocketTransformer.upgrade(req);
          await wsHandle(Request(req), socket, null);
        } else {
          await httpHandle(
              RequestInternal(req), ResponseInternal(req.response), null);
        }
      }
    }

    request();
  }

  void tcpRequest(
      FutureOr<void> Function(
              Socket client, void Function(Socket client, String? err)? done)
          appHandle) {
    tcpRequest() async {
      await _listened.future;
      if (_tcp != null) {
        await for (var client in _tcp!) {
          await appHandle(client, null);
        }
      }
    }

    tcpRequest();
  }

  void udpRequest(
      FutureOr<void> Function(RawDatagramSocket socket,
              void Function(RawDatagramSocket socket, String? err)? done)
          appHandle) {
    udpRequest() async {
      await _listened.future;
      if (_udp != null) {
        await appHandle(_udp!, null);
      }
    }

    udpRequest();
  }
}

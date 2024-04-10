part of router;

class Route {
  final List _stack = [];
  late String _path;

  Route(String path) {
    _path = path;
  }

  ///分发req,res给当前route下的handle
  Future<void> dispatch(HttpRequestWrapper req, HttpResponseWrapper res,
      Completer<String?> done) async {
    var stack = _stack;
    var method = req.inner.method;
    var idx = 0;
    String? err;
    while (true) {
      if (err == 'route') {
        done.complete('');
        return;
      }

      if (err == 'router' || err == 'finish') {
        done.complete(err);
        return;
      }

      Layer layer;
      try {
        layer = stack[idx++];
      } on RangeError {
        done.complete(err);
        return;
      }

      if (!_isWebSocket(layer, method) && layer.method != method) {
        continue;
      } else {
        var next = Completer<String?>();
        err != null && err.isNotEmpty
            ? await layer.handleError(err, req, res, next)
            : await layer.handleRequest(req, res, next);
        err = await next.future;
      }
    }
  }

  Route request(String method, Function callback) {
    Layer layer;
    if (method == WebSocketMethod.webSocket) {
      layer = WebSocketHandleLayer('/', callback);
    } else {
      layer = HttpHandleLayer('/', callback);
    }
    layer.method = method;
    _stack.add(layer);
    return this;
  }

  bool _isWebSocket(Layer layer, String method) {
    return method == HttpMethod.httpGet &&
        layer.method == WebSocketMethod.webSocket;
  }
}

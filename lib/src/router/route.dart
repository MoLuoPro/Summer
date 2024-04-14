part of router;

abstract class Route {
  final List _stack = [];
  // late String _path;

  // Route(String path) {
  //   _path = path;
  // }

  ///分发req,res给当前route下的handle
  Future<void> dispatch(List params, Completer<String?> done);

  bool canHandle(Layer layer, String method);

  Route request(String method, Function callback) {
    Layer layer;
    switch (method) {
      case HttpMethod.httpPost:
      case HttpMethod.httpGet:
      case HttpMethod.httpHead:
      case HttpMethod.httpOptions:
      case HttpMethod.httpPatch:
      case HttpMethod.httpPut:
      case HttpMethod.httpDelete:
        layer = HttpHandleLayer('/', callback);
        break;
      case WebSocketMethod.name:
        layer = WebSocketHandleLayer('/', callback);
        break;
      case TCPMethod.name:
        layer = TCPHandleLayer(callback);
        break;
      case UDPMethod.name:
        layer = UDPHandleLayer(callback);
        break;
      default:
        throw Exception('Method does not exist');
    }
    layer.method = method;
    _stack.add(layer);
    return this;
  }
}

class HttpRoute extends Route {
  ///遍历[_stack],将参数分发给匹配的[Layer]
  @override
  Future<void> dispatch(List params, Completer<String?> done) async {
    Request req = params[0];
    Response res = params[1];
    req as RequestInternal;
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

      HandleLayer layer;
      try {
        layer = stack[idx++];
      } on RangeError {
        done.complete(err);
        return;
      }

      if (!canHandle(layer, method)) {
        continue;
      } else {
        var next = Completer<String?>();
        err != null && err.isNotEmpty
            ? await layer.handleError([err, req, res], next)
            : await layer.handleRequest([req, res], next);
        err = await next.future;
      }
    }
  }

  @override
  bool canHandle(Layer layer, String method) {
    return layer.method == method;
  }
}

class WebSocketRoute extends Route {
  @override
  bool canHandle(Layer layer, String method) {
    return method == HttpMethod.httpGet && layer.method == WebSocketMethod.name;
  }

  @override
  Future<void> dispatch(List params, Completer<String?> done) async {
    Request req = params[0];
    WebSocket ws = params[1];
    req as RequestInternal;
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

      HandleLayer layer;
      try {
        layer = stack[idx++];
      } on RangeError {
        done.complete(err);
        return;
      }

      if (!canHandle(layer, method)) {
        continue;
      } else {
        var next = Completer<String?>();
        err != null && err.isNotEmpty
            ? await layer.handleError([err, req, ws], next)
            : await layer.handleRequest([req, ws], next);
        err = await next.future;
      }
    }
  }
}

class TCPRoute extends Route {
  @override
  bool canHandle(Layer layer, String method) {
    return layer.method == TCPMethod.name;
  }

  @override
  Future<void> dispatch(List params, Completer<String?> done) async {
    Socket cl = params[0];
    var stack = _stack;
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

      HandleLayer layer;
      try {
        layer = stack[idx++];
      } on RangeError {
        done.complete(err);
        return;
      }

      if (!canHandle(layer, '')) {
        continue;
      } else {
        var next = Completer<String?>();
        err != null && err.isNotEmpty
            ? await layer.handleError([err, cl], next)
            : await layer.handleRequest([cl], next);
        err = await next.future;
      }
    }
  }
}

class UDPRoute extends Route {
  @override
  bool canHandle(Layer layer, String method) {
    return layer.method == UDPMethod.name;
  }

  @override
  Future<void> dispatch(List params, Completer<String?> done) async {
    RawDatagramSocket cl = params[0];
    var stack = _stack;
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

      HandleLayer layer;
      try {
        layer = stack[idx++];
      } on RangeError {
        done.complete(err);
        return;
      }

      if (!canHandle(layer, '')) {
        continue;
      } else {
        var next = Completer<String?>();
        err != null && err.isNotEmpty
            ? await layer.handleError([err, cl], next)
            : await layer.handleRequest([cl], next);
        err = await next.future;
      }
    }
  }
}

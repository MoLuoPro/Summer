part of router;

class Route {
  List _stack = [];
  late String _path;

  Route(String path) {
    _path = path;
  }

  ///分发req,res给当前route下的handle
  Future<void> dispatch(
      HttpRequest req, HttpResponse res, Completer<String?> done) async {
    var stack = _stack;
    var method = req.method;
    var idx = 0;
    String? err = '';
    while (true) {
      if (err == 'route') {
        done.complete('');
        return;
      }

      if (err == 'router') {
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

      if (layer.method != method) {
        continue;
      } else if (err != null && err.isNotEmpty) {
        var next = Completer<String?>();
        layer.handleError(err, req, res, next);
        err = await next.future;
      } else {
        var next = Completer<String?>();
        layer.handleRequest(req, res, next);
        err = await next.future;
      }
    }
  }

  Route request(String method, Function callback) {
    var layer = HandleLayer('/', callback);
    layer.method = method;
    _stack.add(layer);
    return this;
  }
}

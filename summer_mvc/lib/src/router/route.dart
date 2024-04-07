part of router;

class Route {
  List _stack = [];
  late String _path;

  Route(String path) {
    _path = path;
  }

  dispatch(HttpRequest req, HttpResponse res, Function done) {
    int sync = 0;
    int idx = 0;
    var stack = _stack;
    String method = req.method;

    void next({String err = ''}) {
      if (err == 'route') {
        return done('');
      }

      if (err == 'router') {
        return done(err);
      }

      if (sync++ > 100) {
        Future.microtask(() => next());
      }
      Layer layer;
      try {
        layer = stack[idx++];
      } on RangeError {
        return done(err);
      }
      if (layer.method != method) {
        next(err: err);
      } else if (err != '') {
        layer.handleError(err, req, res, next);
      } else {
        layer.handleRequest(req, res, next);
      }
      sync = 0;
    }

    next();
  }
}

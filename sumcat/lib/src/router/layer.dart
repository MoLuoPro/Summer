part of router;

/// 对中间件以及路由的封装
class Layer {
  late String name;
  late String _path;
  late String method;
  late Function _fn;
  late Router router;

  Layer(String path, Function fn) {
    _path = path;
    _fn = fn;
  }

  handleRequest(HttpRequest req, HttpResponse res, Function next) {
    var funcMirror = (reflect(next) as ClosureMirror).function;
    if (funcMirror.parameters.length > 3) {
      return next();
    }
    try {
      _fn(req, res, next);
    } catch (err) {
      next(err);
    }
  }

  handleError(String err, HttpRequest req, HttpResponse res, Function next) {
    var funcMirror = (reflect(next) as ClosureMirror).function;
    if (funcMirror.parameters.length != 4) {
      return next(err);
    }
    try {
      _fn(err, req, res, next);
    } catch (err) {
      next(err);
    }
  }
}

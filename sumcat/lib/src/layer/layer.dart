import 'dart:io';
import 'dart:mirrors';

import '../router/router.dart';

/// 对中间件以及路由的封装
abstract class Layer {
  late String name;
  late String _path;
  late String method;
  late Function _fn;
  Route? route;

  Layer(String path, Function fn) {
    _path = path;
    _fn = fn;
  }

  bool match(String path) {
    return path == _path;
  }

  void handleRequest(
      HttpRequest req, HttpResponse res, void Function({String err}) next) {
    var funcMirror = (reflect(next) as ClosureMirror).function;
    if (funcMirror.parameters.length > 3) {
      next();
      return;
    }
    try {
      _fn(req, res, next);
    } catch (err) {
      next(err: err.toString());
    }
  }

  void handleError(
      String err, HttpRequest req, HttpResponse res, Function next) {
    var funcMirror = (reflect(next) as ClosureMirror).function;
    if (funcMirror.parameters.length != 4) {
      next(err);
      return;
    }
    try {
      _fn(err, req, res, next);
    } catch (err) {
      next(err);
    }
  }
}

class HandleLayer extends Layer {
  HandleLayer(String path, Function fn) : super(path, fn);
}

class MiddlewareLayer extends Layer {
  MiddlewareLayer(String path, Function fn) : super(path, fn);
}

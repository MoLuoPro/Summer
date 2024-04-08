import 'dart:async';
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

  Future<void> handleRequest(
      HttpRequest req, HttpResponse res, Completer<String?> next) async {
    // var funcMirror = (reflect(next) as ClosureMirror).function;
    // if (funcMirror.parameters.length > 3) {
    //   next();
    //   return;
    // }
    // try {
    //   _fn(req, res, next);
    // } catch (err) {
    //   next(err: err.toString());
    // }
    try {
      await _fn(req, res, next);
    } catch (err) {
      next.complete(err.toString());
    }
  }

  Future<void> handleError(String? err, HttpRequest req, HttpResponse res,
      Completer<String?> next) async {
    // var funcMirror = (reflect(next) as ClosureMirror).function;
    // if (funcMirror.parameters.length != 4) {
    //   next(err);
    //   return;
    // }
    try {
      await _fn(err, req, res, next);
    } catch (err) {
      next.complete(err.toString());
    }
  }
}

class HandleLayer extends Layer {
  HandleLayer(String path, Function fn) : super(path, fn);
}

class MiddlewareLayer extends Layer {
  MiddlewareLayer(String path, Function fn) : super(path, fn);
}

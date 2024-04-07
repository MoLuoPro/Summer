library router;

import 'dart:io';
import 'dart:mirrors';

part './lazy_router.dart';
part './layer.dart';
part './route.dart';

class Router {
  List<Layer> _stack = [];

  Router use({String path = '/', required List<Function> fns}) {
    if (fns.isEmpty) {
      ArgumentError.notNull("fns");
    }
    for (var fn in fns) {
      var layer = Layer(path, fn);
      _stack.add(layer);
    }
    return this;
  }

  Router route(String path) {
    var route = Route(path);
    var layer = Layer(path, route.dispatch);
    layer.router = this;
    _stack.add(layer);
    return this;
  }

  void handle(HttpRequest req, HttpResponse res, Function? done) {
    int sync = 0;
    int idx = 0;

    void next({String err = ''}) {
      if (sync++ > 100) {
        Future.microtask(() => done?.call());
      }
    }

    next();
  }

  Router request(String method, Function callback) {
    var layer = Layer('/', callback);
    layer.method = method;
    _stack.add(layer);
    return this;
  }
}

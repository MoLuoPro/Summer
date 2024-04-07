library router;

import 'dart:io';

import '../layer/layer.dart';

part './route.dart';

class Router {
  List<Layer> _stack = [];
  Map<String, List<void Function(String name, Function fn)>> paramCallbacks =
      {};

  Router use({String path = '/', required List<Function> fns}) {
    if (fns.isEmpty) {
      ArgumentError.notNull("fns");
    }
    for (var fn in fns) {
      var layer = MiddlewareLayer(path, fn);
      _stack.add(layer);
    }
    return this;
  }

  Route route(String path) {
    var route = Route(path);
    var layer = HandleLayer(path, route.dispatch);
    layer.route = route;
    _stack.add(layer);
    return route;
  }

  void param(String name, void Function(String name, Function fn) fn) {
    paramCallbacks[name] ??= [];
    paramCallbacks[name]?.add(fn);
  }

  void handle(HttpRequest req, HttpResponse res, Function done) {
    var sync = 0;
    var idx = 0;

    void next({String err = ''}) {
      var matched = false;
      var layerError = err == 'route' ? '' : err;
      Layer? layer;
      Route? route;

      if (layerError == 'router') {
        Future.microtask(() => done());
        return;
      }

      if (idx >= _stack.length) {
        Future.microtask(() => done(layerError));
        return;
      }

      if (sync++ > 100) {
        Future.microtask(() => done());
        return;
      }

      while (!matched && idx < _stack.length) {
        layer = _stack[idx];
        var path = req.uri;
        route = layer.route;
        matched = layer.match(path.path);
      }

      if (!matched) {
        done();
        return;
      }

      if (err != '') {
        next(err: layerError != '' ? layerError : err);
      } else if (route != null) {
        layer?.handleRequest(req, res, next);
      } else {}
    }

    next();
  }

  void _processParams(HttpRequest req, HttpResponse res, Function done) {
    void paramCallback() {}
    void param(String? err) {}
  }
}

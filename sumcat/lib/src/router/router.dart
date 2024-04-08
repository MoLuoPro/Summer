library router;

import 'dart:async';
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

  void handle(HttpRequest req, HttpResponse res,
      void Function(HttpRequest, HttpResponse, String?)? done) async {
    String? err;
    var idx = 0;
    String? layerError;
    while (true) {
      Layer? layer;
      Route? route;
      layerError = err == 'route' ? '' : err;
      if (layerError == 'router') {
        Future.microtask(() => done?.call(req, res, ''));
        break;
      }

      if (idx >= _stack.length) {
        Future.microtask(() => done?.call(req, res, layerError));
        break;
      }

      var match = false;
      while (!match && idx < _stack.length) {
        layer = _stack[idx++];
        var path = req.uri;
        route = layer.route;
        match = layer.match(path.path);
        if (!match) {
          continue;
        }
        if (route == null) {
          continue;
        }
        if (layerError != null && layerError.isNotEmpty) {
          match = false;
        }
      }

      if (!match) {
        done?.call(req, res, '');
        break;
      }

      if (err != null && err.isNotEmpty) {
        err = layerError != null && layerError.isNotEmpty ? layerError : err;
      } else if (route != null) {
        var next = Completer<String?>();
        await layer?.handleRequest(req, res, next);
        err = await next.future;
      } else {}
    }
  }

  void _processParams(HttpRequest req, HttpResponse res, Function done) {
    void paramCallback() {}
    void param(String? err) {}
  }
}

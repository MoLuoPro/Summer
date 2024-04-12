library router;

import 'dart:async';
import 'dart:io';

import 'package:sumcat/src/http/http.dart';

import '../layer/layer.dart';

part './route.dart';

abstract class Router {
  final List<Layer> _stack = [];
  Router use({String path = '/', required List fns});
  Router useRouter({String path = '/', required Router router});
  Route route(String path);
  Future<void> handle(List params, Function? done);
}

class HttpRouter extends Router implements HttpMethod {
  final Map<String, List<Function>> _params = {};

  @override
  HttpRouter use({String path = '/', required List fns}) {
    for (var fn in fns) {
      var layer = HttpMiddlewareLayer(path, fn);
      _stack.add(layer);
    }
    return this;
  }

  @override
  HttpRouter useRouter({String path = '/', required Router router}) {
    var layer = HttpRouterLayer(path, (router as HttpRouter).handle);
    _stack.add(layer);
    return this;
  }

  @override
  Route route(String path) {
    var route = HttpRoute(path);
    var layer = HttpRouteLayer(path, route.dispatch);
    layer.route = route;
    _stack.add(layer);
    return route;
  }

  void param(
      String name,
      void Function(HttpRequestWrapper, HttpResponseWrapper, Completer<String?>,
              dynamic, String name)
          fn) {
    _params[name] ??= [];
    _params[name]?.add(fn);
  }

  @override
  Future<void> handle(List params, Function? done) async {
    HttpRequestWrapper req = params[0];
    HttpResponseWrapper res = params[1];
    String? err;
    String? layerError;
    var idx = 0;
    String removed = '';
    String parentPath = (req as HttpRequestWrapperInternal).baseUrl;
    Map<String, Map<String, dynamic>> paramCalled = {};

    while (true) {
      Layer? layer;
      Route? route;
      layerError = err == 'route' ? '' : err;
      if (layerError == 'router' || layerError == 'finish') {
        Future.microtask(() => done?.call(req, res, ''));
        break;
      }

      if (idx >= _stack.length) {
        Future.microtask(() => done?.call(req, res, layerError));
        break;
      }

      var match = false;
      if (removed.isNotEmpty) {
        (req as HttpRequestWrapperInternal).baseUrl = parentPath;
        removed = '';
      }

      while (!match && idx < _stack.length) {
        layer = _stack[idx++];
        route = layer.route;
        String path = getPathName(req, layer.path);
        match = layer.match(path);
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
        break;
      }

      req.params.addAll(layer!.param);

      Future<void> processParams(
          Layer layer,
          Map<String, Map<String, dynamic>> called,
          HttpRequestWrapper req,
          HttpResponseWrapper res,
          Future<void> Function([String?]) done) async {
        var keys = layer.keys;
        var keyIdx = 0;
        String? err = '';
        if (keys.isEmpty) {
          return done();
        }
        while (true) {
          if (err != null && err.isNotEmpty) {
            return await done(err);
          }
          if (keyIdx >= keys.length) {
            return await done();
          }
          var key = keys[keyIdx++];
          var paramVal = layer.param[key];
          var paramCallbacks = _params[key];
          var paramCalled = called[key];
          if (paramVal == null || paramCallbacks == null) {
            continue;
          }
          if (paramCalled != null &&
              (paramCalled['match'] == paramVal ||
                  (paramCalled['err'] != null &&
                      paramCalled['error'] != 'route'))) {
            req.params[key] = paramCalled['value'];
            err = paramCalled['error'];
            continue;
          }
          called[key] = paramCalled = {
            'error': null,
            'match': paramVal,
            'value': paramVal
          };
          var i = 0;
          while (true) {
            paramCalled['value'] = req.params[key];
            if (err != null && err.isNotEmpty) {
              paramCalled['error'] = err;
              break;
            }
            Function fn;
            var completer = Completer<String?>();
            if (i >= paramCallbacks.length) {
              break;
            } else {
              try {
                fn = paramCallbacks[i++];
                fn(req, res, completer, paramVal, key);
              } catch (e) {
                err = e.toString();
              } finally {
                if (!completer.isCompleted) {
                  completer.complete('finish');
                }
              }
              err = await completer.future;
            }
          }
        }
      }

      Future<void> trimPrefix(
          Layer layer, String layerError, String layerPath, String path) async {
        if (layerPath.isNotEmpty) {
          if (layerPath != path.substring(0, layerPath.length)) {
            err = layerError;
            return;
          }

          var c = '';
          try {
            c = path[layerPath.length];
          } on RangeError {
            err = layerError;
            return;
          }
          if (c != '/' && c != '.') {
            err = layerError;
            return;
          }

          removed = (req as HttpRequestWrapperInternal).baseUrl += layerPath;
        }
        var next = Completer<String?>();
        if (layer is RouterLayer) {
          await layer.handle([req, res], done);
        } else {
          layer as HandleLayer;
          layerError.isNotEmpty
              ? await layer.handleError([err, req, res], next)
              : await layer.handleRequest([req, res], next);
          layerError = await next.future ?? '';
        }
      }

      await processParams(layer, paramCalled, req, res, ([String? err]) async {
        if (err != null && err.isNotEmpty) {
          err = layerError != null && layerError.isNotEmpty ? layerError : err;
        } else if (layer is HttpRouteLayer) {
          var next = Completer<String?>();
          await layer.handleRequest([req, res], next);
          err = await next.future;
        } else {
          await trimPrefix(
              layer!, layerError ?? '', layer.path, req.inner.uri.path);
        }
      });
    }
  }

  String getPathName(HttpRequestWrapper req, String layerPath) {
    return layerPath == '/'
        ? req.inner.uri.path
        : req.inner.uri.path
            .substring((req as HttpRequestWrapperInternal).baseUrl.length);
  }

  @override
  HttpRouter get(
      String uri,
      List<
              FutureOr<void> Function(HttpRequestWrapper req,
                  HttpResponseWrapper res, Completer<String?> next)>
          callbacks) {
    var route = this.route(uri);
    for (var callback in callbacks) {
      route.request(HttpMethod.httpGet, callback);
    }
    return this;
  }

  @override
  HttpRouter post(
      String uri,
      List<
              FutureOr<void> Function(HttpRequestWrapper req,
                  HttpResponseWrapper res, Completer<String?> next)>
          callbacks) {
    var route = this.route(uri);
    for (var callback in callbacks) {
      route.request(HttpMethod.httpPost, callback);
    }
    return this;
  }

  @override
  HttpMethod delete(String uri, List<HttpHandler> callbacks) {
    var route = this.route(uri);
    for (var callback in callbacks) {
      route.request(HttpMethod.httpDelete, callback);
    }
    return this;
  }

  @override
  HttpMethod head(String uri, List<HttpHandler> callbacks) {
    var route = this.route(uri);
    for (var callback in callbacks) {
      route.request(HttpMethod.httpHead, callback);
    }
    return this;
  }

  @override
  HttpMethod options(String uri, List<HttpHandler> callbacks) {
    var route = this.route(uri);
    for (var callback in callbacks) {
      route.request(HttpMethod.httpOptions, callback);
    }
    return this;
  }

  @override
  HttpMethod patch(String uri, List<HttpHandler> callbacks) {
    var route = this.route(uri);
    for (var callback in callbacks) {
      route.request(HttpMethod.httpPatch, callback);
    }
    return this;
  }

  @override
  HttpMethod put(String uri, List<HttpHandler> callbacks) {
    var route = this.route(uri);
    for (var callback in callbacks) {
      route.request(HttpMethod.httpPut, callback);
    }
    return this;
  }
}

class WebSocketRouter extends Router implements WebSocketMethod {
  final Map<String, List<Function>> _params = {};

  @override
  WebSocketRouter use({String path = '/', required List fns}) {
    // for (var fn in fns) {
    //   var layer = HttpMiddlewareLayer(path, fn);
    //   _stack.add(layer);
    // }
    // return this;
    throw UnimplementedError();
  }

  @override
  WebSocketRouter useRouter({String path = '/', required Router router}) {
    var layer = WebSocketRouterLayer(path, (router as WebSocketRouter).handle);
    _stack.add(layer);
    return this;
  }

  @override
  Route route(String path) {
    var route = WebSocketRoute(path);
    var layer = WebSocketRouteLayer(path, route.dispatch);
    layer.route = route;
    _stack.add(layer);
    return route;
  }

  void param(
      String name,
      void Function(HttpRequestWrapper req, WebSocket ws,
              Completer<String?> next, dynamic value, String name)
          fn) {
    _params[name] ??= [];
    _params[name]?.add(fn);
  }

  @override
  Future<void> handle(List params, Function? done) async {
    HttpRequestWrapper req = params[0];
    WebSocket ws = params[1];
    String? err;
    String? layerError;
    var idx = 0;
    String removed = '';
    String parentPath = (req as HttpRequestWrapperInternal).baseUrl;
    Map<String, Map<String, dynamic>> paramCalled = {};

    while (true) {
      Layer? layer;
      Route? route;
      layerError = err == 'route' ? '' : err;
      if (layerError == 'router' || layerError == 'finish') {
        Future.microtask(() => done?.call(req, ws, ''));
        break;
      }

      if (idx >= _stack.length) {
        Future.microtask(() => done?.call(req, ws, layerError));
        break;
      }

      var match = false;
      if (removed.isNotEmpty) {
        (req as HttpRequestWrapperInternal).baseUrl = parentPath;
        removed = '';
      }

      while (!match && idx < _stack.length) {
        layer = _stack[idx++];
        route = layer.route;
        String path = getPathName(req, layer.path);
        match = layer.match(path);
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
        break;
      }

      req.params.addAll(layer!.param);

      Future<void> processParams(
          Layer layer,
          Map<String, Map<String, dynamic>> called,
          HttpRequestWrapper req,
          WebSocket ws,
          Future<void> Function([String?]) done) async {
        var keys = layer.keys;
        var keyIdx = 0;
        String? err = '';
        if (keys.isEmpty) {
          return done();
        }
        while (true) {
          if (err != null && err.isNotEmpty) {
            return await done(err);
          }
          if (keyIdx >= keys.length) {
            return await done();
          }
          var key = keys[keyIdx++];
          var paramVal = layer.param[key];
          var paramCallbacks = _params[key];
          var paramCalled = called[key];
          if (paramVal == null || paramCallbacks == null) {
            continue;
          }
          if (paramCalled != null &&
              (paramCalled['match'] == paramVal ||
                  (paramCalled['err'] != null &&
                      paramCalled['error'] != 'route'))) {
            req.params[key] = paramCalled['value'];
            err = paramCalled['error'];
            continue;
          }
          called[key] = paramCalled = {
            'error': null,
            'match': paramVal,
            'value': paramVal
          };
          var i = 0;
          while (true) {
            paramCalled['value'] = req.params[key];
            if (err != null && err.isNotEmpty) {
              paramCalled['error'] = err;
              break;
            }
            Function fn;
            var completer = Completer<String?>();
            if (i >= paramCallbacks.length) {
              break;
            } else {
              try {
                fn = paramCallbacks[i++];
                fn(req, ws, completer, paramVal, key);
              } catch (e) {
                err = e.toString();
              } finally {
                if (!completer.isCompleted) {
                  completer.complete('finish');
                }
              }
              err = await completer.future;
            }
          }
        }
      }

      Future<void> trimPrefix(
          Layer layer, String layerError, String layerPath, String path) async {
        if (layerPath.isNotEmpty) {
          if (layerPath != path.substring(0, layerPath.length)) {
            err = layerError;
            return;
          }

          var c = '';
          try {
            c = path[layerPath.length];
          } on RangeError {
            err = layerError;
            return;
          }
          if (c != '/' && c != '.') {
            err = layerError;
            return;
          }

          removed = (req as HttpRequestWrapperInternal).baseUrl += layerPath;
        }
        var next = Completer<String?>();
        if (layer is RouterLayer) {
          await layer.handle([req, ws], done);
        } else {
          layer as HandleLayer;
          layerError.isNotEmpty
              ? await layer.handleError([err, req, ws], next)
              : await layer.handleRequest([req, ws], next);
          layerError = await next.future ?? '';
        }
      }

      await processParams(layer, paramCalled, req, ws, ([String? err]) async {
        if (err != null && err.isNotEmpty) {
          err = layerError != null && layerError.isNotEmpty ? layerError : err;
        } else if (layer is HandleLayer) {
          var next = Completer<String?>();
          await layer.handleRequest([req, ws], next);
          err = await next.future;
        } else {
          await trimPrefix(
              layer!, layerError ?? '', layer.path, req.inner.uri.path);
        }
      });
    }
  }

  String getPathName(HttpRequestWrapper req, String layerPath) {
    return layerPath == '/'
        ? req.inner.uri.path
        : req.inner.uri.path
            .substring((req as HttpRequestWrapperInternal).baseUrl.length);
  }

  @override
  WebSocketRouter ws(String uri, List<WebSocketHandler> callbacks) {
    var route = this.route(uri);
    for (var callback in callbacks) {
      route.request(WebSocketMethod.name, callback);
    }
    return this;
  }
}

class TCPRouter extends Router {
  TCPRouter useTCPRouter({String path = '/', required TCPRouter router}) {
    if (_stack.any((layer) => layer is TCPRouterLayer)) {
      throw TCPError("The current TCP connection already exists.");
    }
    var layer = TCPRouterLayer('/', router.handle);
    _stack.add(layer);
    return this;
  }

  @override
  Future<void> handle(List params, Function? done) async {
    var client = params[0];
    String? err;
    String? layerError;
    var idx = 0;

    while (true) {
      Layer? layer;
      Route? route;
      layerError = err == 'route' ? '' : err;
      if (layerError == 'router' || layerError == 'finish') {
        Future.microtask(() => done?.call(client, ''));
        break;
      }

      if (idx >= _stack.length) {
        Future.microtask(() => done?.call(client, layerError));
        break;
      }

      while (idx < _stack.length) {
        layer = _stack[idx++];
        route = layer.route;
        if (route == null) {
          continue;
        }
        if (layerError != null && layerError.isNotEmpty) {
          break;
        }
      }

      if (err != null && err.isNotEmpty) {
        err = layerError != null && layerError.isNotEmpty ? layerError : err;
      } else {
        layer as HandleLayer;
        var next = Completer<String?>();
        await layer.handleRequest([client], next);
        err = await next.future;
      }
    }
  }

  @override
  Route route(String path) {
    var route = TCPRoute(path);
    var layer = TCPRouteLayer(path, route.dispatch);
    layer.route = route;
    _stack.add(layer);
    return route;
  }

  @override
  Router use({String path = '/', required List fns}) {
    // TODO: implement use
    throw UnimplementedError();
  }

  @override
  Router useRouter({String path = '/', required Router router}) {
    var layer = TCPRouterLayer(path, (router as TCPRouterLayer).handle);
    _stack.add(layer);
    return this;
  }
}

class UDPRouter extends Router {
  UDPRouter useUDPRouter({String path = '/', required UDPRouter router}) {
    if (_stack.any((layer) => layer is UDPRouterLayer)) {
      throw TCPError("The current UDP connection already exists.");
    }
    var layer = UDPRouterLayer('/', router.handle);
    _stack.add(layer);
    return this;
  }

  @override
  Future<void> handle(List params, Function? done) async {
    var client = params[0];
    String? err;
    String? layerError;
    var idx = 0;

    while (true) {
      Layer? layer;
      Route? route;
      layerError = err == 'route' ? '' : err;
      if (layerError == 'router' || layerError == 'finish') {
        Future.microtask(() => done?.call(client, ''));
        break;
      }

      if (idx >= _stack.length) {
        Future.microtask(() => done?.call(client, layerError));
        break;
      }

      while (idx < _stack.length) {
        layer = _stack[idx++];
        route = layer.route;
        if (route == null) {
          continue;
        }
        if (layerError != null && layerError.isNotEmpty) {
          break;
        }
      }

      if (err != null && err.isNotEmpty) {
        err = layerError != null && layerError.isNotEmpty ? layerError : err;
      } else {
        layer as HandleLayer;
        var next = Completer<String?>();
        await layer.handleRequest([client], next);
        err = await next.future;
      }
    }
  }

  @override
  Route route(String path) {
    var route = UDPRoute(path);
    var layer = UDPRouteLayer(path, route.dispatch);
    layer.route = route;
    _stack.add(layer);
    return route;
  }

  @override
  Router use({String path = '/', required List fns}) {
    // TODO: implement use
    throw UnimplementedError();
  }

  @override
  Router useRouter({String path = '/', required Router router}) {
    var layer = UDPRouterLayer(path, (router as UDPRouterLayer).handle);
    _stack.add(layer);
    return this;
  }
}

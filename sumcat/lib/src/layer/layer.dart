import 'dart:async';

import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:sumcat/src/http/http.dart';

import '../router/router.dart';

/// 对中间件以及路由的封装
abstract class Layer {
  late String name;
  late String _path;
  late String method;
  late Function _fn;
  late bool _fastStar;
  late bool _fastSlash;
  late RegExp _regExp;
  late List<String> _keys;
  Route? route;
  Map<String, String> param = {};

  List<String> get keys => _keys;
  String get path => _path;

  Layer(String path, Function fn) {
    _path = path;
    _fn = fn;
    _fastStar = path == '*';
    _fastSlash = path == '/';
    _regExp = pathToRegExp(path,
        parameters: _keys = [], caseSensitive: false, prefix: true);
  }

  bool match(String path) {
    if (_fastSlash) {
      param = {};
      _path = '';
      return true;
    }
    if (_fastStar) {
      param = {'0': _decodeParam(path)};
      _path = path;
      return true;
    }
    List<String> match = RegExpUtils.exec(_regExp, path);
    if (match.isEmpty) {
      param = {};
      _path = '';
      return false;
    }
    param = {};
    _path = match.first;
    for (var i = 1; i < match.length; i++) {
      param[_keys[i - 1]] = _decodeParam(match[i]);
    }
    return true;
  }

  String _decodeParam(String val) {
    try {
      return val = Uri.decodeComponent(val);
    } catch (e) {
      print('Failed to decode param $val');
      rethrow;
    }
  }
}

class RouteLayer extends HandleLayer {
  RouteLayer(String path, Function fn) : super(path, fn);

  @override
  Future<void> _handleError(List params, Completer<String?> next) async {
    await _fn([...params], next);
  }

  @override
  Future<void> _handleRequest(List params, Completer<String?> next) async {
    await _fn([...params], next);
  }

  @override
  bool _requestCondition() {
    return true;
  }

  @override
  bool _errorCondition() {
    return true;
  }
}

class HttpRouteLayer extends RouteLayer {
  HttpRouteLayer(String path, Function fn) : super(path, fn);
}

class WebSocketRouteLayer extends RouteLayer {
  WebSocketRouteLayer(String path, Function fn) : super(path, fn);
}

class TCPRouteLayer extends RouteLayer {
  TCPRouteLayer(String path, Function fn) : super(path, fn);
}

class UDPRouteLayer extends RouteLayer {
  UDPRouteLayer(String path, Function fn) : super(path, fn);
}

abstract class HandleLayer extends Layer {
  HandleLayer(String path, Function fn) : super(path, fn);

  bool _requestCondition();
  bool _errorCondition();

  Future<void> _handleError(List params, Completer<String?> next);

  Future<void> _handleRequest(List params, Completer<String?> next);

  Future<void> handleRequest(
      List<dynamic> params, Completer<String?> next) async {
    try {
      _requestCondition()
          ? await _handleRequest(params, next)
          : next.complete();
    } catch (err) {
      print(err);
      if (err is Error) {
        print(err.stackTrace);
      }
      if (!next.isCompleted) {
        next.complete(err.toString());
      }
    } finally {
      if (!next.isCompleted) {
        next.complete("finish");
      }
    }
  }

  Future<void> handleError(
      List<dynamic> params, Completer<String?> next) async {
    try {
      _errorCondition()
          ? await _handleError(params, next)
          : next.complete(params[0]);
      await _handleError(params, next);
    } catch (err) {
      if (err is Error) {
        print(err.stackTrace);
      } else {
        print(err);
      }
      next.complete(err.toString());
    } finally {
      if (!next.isCompleted) {
        next.complete("err");
      }
    }
  }
}

class HttpHandleLayer extends HandleLayer {
  HttpHandleLayer(String path, Function fn) : super(path, fn);

  @override
  Future<void> _handleError(List params, Completer<String?> next) async {
    await _fn(params[0], params[1], params[2], next);
  }

  @override
  Future<void> _handleRequest(List params, Completer<String?> next) async {
    await _fn(params[0], params[1], next);
  }

  @override
  bool _requestCondition() {
    return _fn is HttpRequestHandle;
  }

  @override
  bool _errorCondition() {
    return _fn is HttpErrorHandler;
  }
}

class WebSocketHandleLayer extends HandleLayer {
  WebSocketHandleLayer(String path, Function fn) : super(path, fn);

  @override
  Future<void> _handleError(List params, Completer<String?> next) async {
    await _fn(params[0], params[1], params[2], next);
  }

  @override
  Future<void> _handleRequest(List params, Completer<String?> next) async {
    await _fn(params[0], params[1], next);
  }

  @override
  bool _requestCondition() {
    return _fn.runtimeType is WebSocketRequestHandle;
  }

  @override
  bool _errorCondition() {
    return _fn.runtimeType is WebSocketErrorHandler;
  }
}

class TCPHandleLayer extends HandleLayer {
  TCPHandleLayer(Function fn) : super('/', fn);

  @override
  Future<void> _handleError(List params, Completer<String?> next) async {
    await _fn(params[0], params[1], next);
  }

  @override
  Future<void> _handleRequest(List params, Completer<String?> next) async {
    await _fn(params[0], next);
  }

  @override
  bool _errorCondition() {
    return _fn.runtimeType is TCPSocketHandler;
  }

  @override
  bool _requestCondition() {
    return _fn.runtimeType is TCPSocketErrorHandler;
  }
}

class UDPHandleLayer extends HandleLayer {
  UDPHandleLayer(Function fn) : super('/', fn);

  @override
  Future<void> _handleError(List params, Completer<String?> next) async {
    await _fn(params[0], params[1], next);
  }

  @override
  Future<void> _handleRequest(List params, Completer<String?> next) async {
    await _fn(params[0], next);
  }

  @override
  bool _errorCondition() {
    return _fn.runtimeType is UDPSocketHandler;
  }

  @override
  bool _requestCondition() {
    return _fn.runtimeType is UDPSocketErrorHandler;
  }
}

class HttpMiddlewareLayer extends HandleLayer {
  HttpMiddlewareLayer(String path, Function fn) : super(path, fn);

  @override
  Future<void> _handleError(List params, Completer<String?> next) async {
    await _fn(params[0], params[1], params[2], next);
  }

  @override
  Future<void> _handleRequest(List params, Completer<String?> next) async {
    await _fn(params[0], params[1], next);
  }

  @override
  bool _errorCondition() {
    return _fn.runtimeType is HttpHandler;
  }

  @override
  bool _requestCondition() {
    return _fn.runtimeType is HttpErrorHandler;
  }
}

abstract class RouterLayer extends Layer {
  RouterLayer(String path, Function fn) : super(path, fn);

  Future<void> handle(List params, Function? done);
}

class WebSocketRouterLayer extends RouterLayer {
  WebSocketRouterLayer(String path, Function fn) : super(path, fn);

  @override
  Future<void> handle(List params, Function? done) async {
    var req = params[0];
    var ws = params[1];
    await _fn([req, ws], done);
  }
}

class HttpRouterLayer extends RouterLayer {
  HttpRouterLayer(String path, Function fn) : super(path, fn);

  @override
  Future<void> handle(List params, Function? done) async {
    var req = params[0];
    var res = params[1];
    await _fn([req, res], done);
  }
}

class TCPRouterLayer extends RouterLayer {
  TCPRouterLayer(String path, Function fn) : super(path, fn);

  @override
  Future<void> handle(List params, Function? done) async {
    var client = params[0];
    await _fn([client], done);
  }
}

class UDPRouterLayer extends RouterLayer {
  UDPRouterLayer(String path, Function fn) : super(path, fn);

  @override
  Future<void> handle(List params, Function? done) async {
    var client = params[0];
    await _fn([client], done);
  }
}

class RegExpUtils {
  static List<String> exec(RegExp regExp, String path) {
    Match? match = regExp.firstMatch(path);
    if (match != null) {
      // 提取所有匹配的组
      List<String> matchedGroups = [];
      for (int i = 0; i <= match.groupCount; i++) {
        // 使用 group 方法来获取匹配的组
        String? group = match.group(i);
        if (group != null) {
          matchedGroups.add(group);
        }
      }
      return matchedGroups;
    }
    return [];
  }
}

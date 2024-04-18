import 'dart:async';
import 'dart:io';

import 'package:path_to_regexp/path_to_regexp.dart';
import '../http/http.dart';

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
  Future<void> _handleError(List params, [Completer<String?>? next]) async {
    await _fn([...params], next);
  }

  @override
  Future<void> _handleRequest(List params, [Completer<String?>? next]) async {
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

  @override
  bool _isSimple(List params) {
    return false;
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
  bool _isSimple(List params);

  Future<void> _handleError(List params, [Completer<String?> next]);

  Future<void> _handleRequest(List params, [Completer<String?> next]);

  Future<void> handleRequest(
      List<dynamic> params, Completer<String?> next) async {
    try {
      if (_requestCondition()) {
        if (_isSimple(params)) {
          await _handleRequest(params);
          next.complete();
        } else {
          await _handleRequest(params, next);
        }
      } else {
        next.complete();
      }
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
      if (_errorCondition()) {
        if (_isSimple(params)) {
          await _handleError(params);
          next.complete();
        } else {
          await _handleError(params, next);
        }
      } else {
        next.complete(params[0]);
      }
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

  // Future<dynamic> sendTask(Request req, Function fn) async {
  //   req as RequestInternal;
  //   var port = req.threadPool!.sendPorts[req.threadId!];
  //   port.send(Task(fn, port, req.threadId!).toMap());
  //   await for (var result in req.threadPool!.streamController.stream) {
  //     result as Result;
  //     if (req.threadId == result.threadId) {
  //       return result.data;
  //     }
  //   }
  // }

  @override
  Future<void> _handleError(List params, [Completer<String?>? next]) async {
    Request req = params[0];
    Response res = params[1];
    req as RequestInternal;
    Future<dynamic> fn() async => await (next == null
        ? _fn(params[0], params[1], params[2])
        : _fn(params[0], params[1], params[2], next));
    // dynamic result = await (req.threadId != null && req.threadPool != null
    //     ? sendTask(req, fn)
    //     : fn());
    var result = await fn();
    await processHandle(req, res, result);
  }

  @override
  Future<void> _handleRequest(List params, [Completer<String?>? next]) async {
    Request req = params[0];
    Response res = params[1];
    req as RequestInternal;

    Future<dynamic> fn() async {
      return await (next == null
          ? _fn(params[0], params[1])
          : _fn(params[0], params[1], next));
    }

    // dynamic result = await (req.threadId != null && req.threadPool != null
    //     ? sendTask(req, fn)
    //     : fn());
    var result = await fn();
    await processHandle(req, res, result);
  }

  Future<void> processHandle(Request req, Response res, dynamic result) async {
    if (result != null) {
      if (result is List) {
        res.sendAll(result);
      } else {
        res.send(result);
      }
    }
  }

  @override
  bool _requestCondition() {
    return _fn is HttpHandler || _fn is HttpSimpleHandler;
  }

  @override
  bool _errorCondition() {
    return _fn is HttpErrorHandler || _fn is HttpErrorSimpleHandler;
  }

  @override
  bool _isSimple(List params) {
    // HttpSimpleHandler || HttpErrorSimpleHandler
    return (param.length == 2 && params[0] is Request) ||
        (param.length == 3 && params[0] is String?);
  }
}

class WebSocketHandleLayer extends HandleLayer {
  WebSocketHandleLayer(String path, Function fn) : super(path, fn);

  @override
  Future<void> _handleError(List params, [Completer<String?>? next]) async {
    await (next == null
        ? _fn(params[0], params[1], params[2])
        : _fn(params[0], params[1], params[2], next));
  }

  @override
  Future<void> _handleRequest(List params, [Completer<String?>? next]) async {
    await (next == null
        ? _fn(params[0], params[1])
        : _fn(params[0], params[1], next));
  }

  @override
  bool _requestCondition() {
    return _fn is WebSocketHandler || _fn is WebSocketSimpleHandler;
  }

  @override
  bool _errorCondition() {
    return _fn is WebSocketErrorHandler || _fn is WebSocketErrorSimpleHandler;
  }

  @override
  bool _isSimple(List params) {
    //_fn is WebSocketSimpleHandler || _fn is WebSocketErrorSimpleHandler
    return (param.length == 2 && params[0] is Request) ||
        (param.length == 3 && params[0] is String?);
  }
}

class TCPHandleLayer extends HandleLayer {
  TCPHandleLayer(Function fn) : super('/', fn);

  @override
  Future<void> _handleError(List params, [Completer<String?>? next]) async {
    await (next == null
        ? _fn(params[0], params[1])
        : _fn(params[0], params[1], next));
  }

  @override
  Future<void> _handleRequest(List params, [Completer<String?>? next]) async {
    await (next == null ? _fn(params[0]) : _fn(params[0], next));
  }

  @override
  bool _errorCondition() {
    return _fn is TCPSocketErrorHandler || _fn is TCPSocketErrorSimpeHandler;
  }

  @override
  bool _requestCondition() {
    return _fn is TCPSocketHandler || _fn is TCPSocketSimpleHandler;
  }

  @override
  bool _isSimple(List params) {
    // TCPSocketSimpleHandler || TCPSocketErrorSimpeHandler
    return (param.length == 1 && params[0] is Socket) ||
        (param.length == 2 && params[0] is String?);
  }
}

class UDPHandleLayer extends HandleLayer {
  UDPHandleLayer(Function fn) : super('/', fn);

  @override
  Future<void> _handleError(List params, [Completer<String?>? next]) async {
    await (next == null
        ? _fn(params[0], params[1])
        : _fn(params[0], params[1], next));
  }

  @override
  Future<void> _handleRequest(List params, [Completer<String?>? next]) async {
    await (next == null ? _fn(params[0]) : _fn(params[0], next));
  }

  @override
  bool _errorCondition() {
    return _fn is UDPSocketErrorHandler || _fn is UDPSocketErrorSimpleHandler;
  }

  @override
  bool _requestCondition() {
    return _fn is UDPSocketHandler || _fn is UDPSocketSimpleHandler;
  }

  @override
  bool _isSimple(List params) {
    // UDPSocketSimpleHandler || UDPSocketErrorSimpleHandler;
    return (param.length == 1 && params[0] is RawDatagramSocket) ||
        (param.length == 2 && params[0] is String?);
  }
}

class HttpMiddlewareLayer extends HandleLayer {
  HttpMiddlewareLayer(String path, Function fn) : super(path, fn);

  @override
  Future<void> _handleError(List params, [Completer<String?>? next]) async {
    await (next == null
        ? _fn(params[0], params[1], params[2])
        : _fn(params[0], params[1], params[2], next));
  }

  @override
  Future<void> _handleRequest(List params, [Completer<String?>? next]) async {
    await (next == null
        ? _fn(params[0], params[1])
        : _fn(params[0], params[1], next));
  }

  @override
  bool _errorCondition() {
    return _fn is HttpErrorHandler || _fn is HttpErrorSimpleHandler;
  }

  @override
  bool _requestCondition() {
    return _fn is HttpHandler || _fn is HttpSimpleHandler;
  }

  @override
  bool _isSimple(List params) {
    return (param.length == 2 && params[0] is Request) ||
        (param.length == 3 && params[0] is String?);
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

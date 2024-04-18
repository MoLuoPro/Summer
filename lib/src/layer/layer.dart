import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:reflectable/reflectable.dart';
import '../http/http.dart';

import '../router/router.dart';

const methodReflectable = MethodReflectable();

/// 对中间件以及路由的封装
@methodReflectable
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

  Future<void> _handleError(List params, Completer<String?> next) async {
    await Function.apply(_fn, [...params, next]);
  }

  Future<void> _handleRequest(List params, Completer<String?> next) async {
    await Function.apply(_fn, [...params, next]);
  }

  Future<void> handleRequest(
      List<dynamic> params, Completer<String?> next) async {
    try {
      if (_requestCondition()) {
        await _handleRequest(params, next);
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
        await _handleError(params, next);
      } else {
        next.complete(params[0]);
      }
    } catch (err) {
      print(err);
      if (err is Error) {
        print(err.stackTrace);
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
  Future<void> _handleError(List params, [Completer<String?>? next]) async {
    Request req = params[1];
    Response res = params[2];
    req as RequestInternal;
    await processHandle(req, res, Function.apply(_fn, [...params, next]));
  }

  @override
  Future<void> _handleRequest(List params, Completer<String?> next) async {
    Request req = params[0];
    Response res = params[1];
    req as RequestInternal;
    await processHandle(req, res, Function.apply(_fn, [...params, next]));
  }

  Future<void> processHandle(Request req, Response res, dynamic result) async {
    if (result != null) {
      if (result is List<int>) {
        var bytes = ByteData(result.length * 4);
        for (int i = 0; i < result.length; i++) {
          bytes.setUint32(i * 4, result[i]);
        }
        res.headers.set('Content-Type', ContentType.binary.value);
        res.sendAll(bytes.buffer.asUint8List());
      } else if (result is List<dynamic>) {
        res.sendAll(result);
        res.headers.set('Content-Type', ContentType.binary.value);
      } else if (result is Stream<List<int>>) {
        var list = await result.fold<List<int>>(
            [], (previous, element) => previous..addAll(element));
        res.sendAll(list);
        res.headers.set('Content-Type', ContentType.binary.value);
      } else if (result is Map<String, Object?>) {
        res.send(jsonEncode(result));
      } else if (result is File) {
        var file = result;
        if (await file.exists()) {
          var fileName = basename(file.path);
          var mimeType = mime(fileName) ?? ContentType.binary.value;
          res.headers
              .set('Content-Disposition', 'attachment; filename="$fileName"');
          res.headers.set('Content-Type', mimeType);
          res.sendAll(await file.readAsBytes());
        } else {
          throw FileSystemException('file dose not exists.', path);
        }
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
}

class WebSocketHandleLayer extends HandleLayer {
  WebSocketHandleLayer(String path, Function fn) : super(path, fn);

  @override
  bool _requestCondition() {
    return _fn is WebSocketHandler || _fn is WebSocketSimpleHandler;
  }

  @override
  bool _errorCondition() {
    return _fn is WebSocketErrorHandler || _fn is WebSocketErrorSimpleHandler;
  }
}

class TCPHandleLayer extends HandleLayer {
  TCPHandleLayer(Function fn) : super('/', fn);

  @override
  bool _errorCondition() {
    return _fn is TCPSocketErrorHandler || _fn is TCPSocketErrorSimpeHandler;
  }

  @override
  bool _requestCondition() {
    return _fn is TCPSocketHandler || _fn is TCPSocketSimpleHandler;
  }
}

class UDPHandleLayer extends HandleLayer {
  UDPHandleLayer(Function fn) : super('/', fn);

  @override
  bool _errorCondition() {
    return _fn is UDPSocketErrorHandler || _fn is UDPSocketErrorSimpleHandler;
  }

  @override
  bool _requestCondition() {
    return _fn is UDPSocketHandler || _fn is UDPSocketSimpleHandler;
  }
}

class HttpMiddlewareLayer extends HandleLayer {
  HttpMiddlewareLayer(String path, Function fn) : super(path, fn);

  @override
  bool _errorCondition() {
    return _fn is HttpErrorHandler || _fn is HttpErrorSimpleHandler;
  }

  @override
  bool _requestCondition() {
    return _fn is HttpHandler || _fn is HttpSimpleHandler;
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

class MethodReflectable extends Reflectable {
  const MethodReflectable()
      : super(invokingCapability, typeRelationsCapability,
            reflectedTypeCapability);
}

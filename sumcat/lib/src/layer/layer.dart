import 'dart:async';
import 'dart:io';

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
  Map<String, dynamic> param = {};

  List<String> get keys => _keys;
  String get path => _path;

  Layer(String path, Function fn) {
    _path = path;
    _fn = fn;
    _fastStar = path == '*';
    _fastSlash = path == '/';
    _regExp = pathToRegExp(path,
        parameters: _keys = [], caseSensitive: false, prefix: true);
    // _regExp = RegExpUtils.pathRegExp(path, _keys = []);
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

  Future<void> handleRequest(HttpRequestWrapper req, HttpResponseWrapper res,
      Completer<String?> next) async {
    try {
      await _fn(req, res, next);
    } catch (err) {
      if (!next.isCompleted) {
        next.complete(err.toString());
      }
    } finally {
      if (!next.isCompleted) {
        next.complete("finish");
      }
    }
  }

  Future<void> handleError(String? err, HttpRequestWrapper req,
      HttpResponseWrapper res, Completer<String?> next) async {
    try {
      await _fn(err, req, res, next);
    } catch (err) {
      next.complete(err.toString());
    } finally {
      if (!next.isCompleted) {
        next.complete("err");
      }
    }
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

class RouteLayer extends Layer {
  RouteLayer(String path, Function fn) : super(path, fn);
}

class HttpHandleLayer extends Layer {
  HttpHandleLayer(String path, Function fn) : super(path, fn);
}

class WebSocketHandleLayer extends Layer {
  WebSocketHandleLayer(String path, Function fn) : super(path, fn);

  @override
  Future<void> handleRequest(HttpRequestWrapper req, HttpResponseWrapper res,
      Completer<String?> next) async {
    try {
      var websocket = await WebSocketTransformer.upgrade(req.inner);
      await _fn(req, websocket);
    } catch (err) {
      if (!next.isCompleted) {
        next.complete(err.toString());
      }
    } finally {
      if (!next.isCompleted) {
        next.complete("finish");
      }
    }
  }

  @override
  Future<void> handleError(String? err, HttpRequestWrapper req,
      HttpResponseWrapper res, Completer<String?> next) async {
    try {
      var websocket = WebSocketTransformer.upgrade(req.inner);
      await _fn(err, req, websocket);
    } catch (err) {
      next.complete(err.toString());
    } finally {
      if (!next.isCompleted) {
        next.complete("err");
      }
    }
  }
}

class MiddlewareLayer extends Layer {
  MiddlewareLayer(String path, Function fn) : super(path, fn);
}

class RouterLayer extends Layer {
  RouterLayer(String path, Function fn) : super(path, fn);

  Future<void> handle(
      HttpRequestWrapper req,
      HttpResponseWrapper res,
      void Function(HttpRequestWrapper, HttpResponseWrapper, String?)?
          done) async {
    await _fn(req, res, done);
  }
}

class RegExpUtils {
  static RegExp pathRegExp(String pattern, List<String> keys) {
    // 将 pattern 中的特殊字符转义
    String regex = pattern.replaceAllMapped(
        RegExp(r'(\.|\$|\^|\{|\[|\(|\||\)|\]|\}|\\|\+|\*)'),
        (Match match) => "\\${match.group(0)}");
    // 将 :param 形式的参数替换为匹配任意非斜杠字符的正则表达式
    regex = regex.replaceAllMapped(RegExp(r':([a-zA-Z]+)'), (Match match) {
      var param = match.group(0);
      if (param != null) {
        keys.add(param.substring(1));
      }
      return "([/]*)";
    });
    return RegExp("^$regex");
  }

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

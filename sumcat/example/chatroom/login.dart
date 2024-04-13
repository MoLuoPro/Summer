import 'dart:async';
import 'dart:convert';

import 'package:sumcat/sumcat.dart';

HttpRouter login = _init();

HttpRouter _init() {
  login = httpRouter();
  login.post('/login', [
    (Request req, Response res, Completer<String?> next) async {
      try {
        var user = await req.body;
        var json = jsonEncode(user);
        print(json);
        res.ok(json);
      } catch (err) {
        res.error('用户名或密码错误');
      }
    }
  ]);
  return login;
}

import 'dart:async';
import 'dart:convert';

import 'package:summer/summer.dart';

HttpRouter login = _init();

HttpRouter _init() {
  login = httpRouter();
  login.post('/login', [
    (Request req, Response res, Completer<String?> next) async {
      try {
        var user = await req.body;
        var json = jsonEncode(user);
        print(json);
        res.sendStatus(200);
        res.send(json);
      } catch (err) {
        res.sendStatus(500);
        res.send('Username or password is incorrect !');
      }
    }
  ]);
  return login;
}

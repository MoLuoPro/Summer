import 'dart:convert';

import 'package:sumcat/sumcat.dart';

HttpRouter login = _init();

HttpRouter _init() {
  login = HttpRouter();
  login.post('/login', [
    (req, res, next) async {
      var json = await utf8.decoder.bind(req.inner).join();
      Map data = jsonDecode(json);
      try {
        Map user = data['_value'];
        res.inner.write(
            user['username'] == 'dart' && user['password'] == '123456'
                ? user
                : null);
      } catch (err) {
        res.inner.write(false);
      }
    }
  ]);
  return login;
}

Map user = {'username': 'dart', 'password': '123456'};

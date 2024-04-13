import 'dart:convert';

import 'package:sumcat/sumcat.dart';

HttpRouter login = _init();

HttpRouter _init() {
  login = httpRouter();
  login.post('/login', [
    (req, res, next) async {
      var json = await utf8.decoder.bind(req.inner).join();
      Map data = jsonDecode(json);
      try {
        Map user = data['_value'];
        json = jsonEncode(user);
        print(json);
        res.inner.write(json);
      } catch (err) {
        res.inner.write(false);
      }
    }
  ]);
  return login;
}

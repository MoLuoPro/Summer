import 'dart:convert';

import 'package:sumcat/sumcat.dart';

Router login = _init();

Router _init() {
  login = Router();
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

import 'dart:async';

import 'package:sumcat/sumcat.dart';

void main() {
  var app = createApp();
  app.get('/index', [
    (Request req, Response res, Completer<String?> next) {
      throw Error();
    },
    (String? err, Request req, Response res, Completer<String?> next) {
      print(err);
    }
  ]);
  app.listen(httpPort: 4000);
}

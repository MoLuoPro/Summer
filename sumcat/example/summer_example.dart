import 'dart:async';
import 'dart:io';
import 'package:sumcat/src/http/http.dart';
import 'package:sumcat/sumcat.dart';

void main() {
  var app = createApplication();
  app.get("/test/:id", [
    (HttpRequestWrapper req, HttpResponse res, Completer<String?> next) {
      res.writeln("1");
      next.complete();
    },
    (HttpRequestWrapper req, HttpResponse res, Completer<String?> next) {
      res.writeln("2");
    }
  ]);
  app.param('id', (req, res, next, value, name) {
    print('$name: $value');
    print(req.params);
    next.complete();
  });
  app.listen(4000);
}

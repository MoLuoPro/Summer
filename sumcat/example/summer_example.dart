import 'dart:async';
import 'dart:io';
import 'package:sumcat/sumcat.dart';

void main() {
  var app = createApplication();
  app.get("/test", [
    (HttpRequest req, HttpResponse res, Completer<String?> next) {
      res.writeln("1");
    },
    (HttpRequest req, HttpResponse res, Completer<String?> next) {
      res.writeln("2");
    }
  ]);
  app.listen(4000);
}

import 'dart:async';
import 'package:sumcat/sumcat.dart';

void main() {
  var app = createApplication();
  app.get("/test/:id", [
    (HttpRequestWrapper req, HttpResponseWrapper res, Completer<String?> next) {
      res.inner.write("1");
      next.complete();
    },
    (HttpRequestWrapper req, HttpResponseWrapper res, Completer<String?> next) {
      res.inner.write("2");
      next.complete();
    }
  ]);
  app.use(path: '/test', fns: [
    (req, res, next) {
      print('use');
      next.complete();
    }
  ]);
  app.param('id', (req, res, next, value, name) {
    print('$name: $value');
    print(req.params);
    next.complete();
  });
  app.listen(4000);
}

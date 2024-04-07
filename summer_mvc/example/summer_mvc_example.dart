import 'dart:io';
import 'package:summer_mvc/summer_mvc.dart';

void main() {
  var app = createApplication();
  app.get("/test", (HttpRequest req, HttpResponse res, Function? next) {
    res.write(req.uri);
  });
  app.listen(3000);
}

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

import '../../sumcat.dart';

serveStatic(String path) {
  var baseUri = Directory.current.uri.resolve(path);
  var baseDir = Directory.fromUri(baseUri);
  return (HttpRequestWrapper req, HttpResponseWrapper res,
      Completer<String?> next) async {
    if (req.inner.method == HttpMethod.httpGet) {
      var uri = baseDir.uri.resolve(req.inner.uri.path.substring(1));
      var file = File.fromUri(uri);
      if (await file.exists()) {
        var fileType = extension(file.path);
        var content = await file.readAsString();
        switch (fileType) {
          case '.html':
            res.inner.headers.set('Content-Type', 'text/html; charset=utf-8');
            break;
          case '.js':
            res.inner.headers
                .set('Content-Type', 'text/javascript; charset=utf-8');
            break;
          case '.css':
            res.inner.headers.set('Content-Type', 'text/css; charset=utf-8');
            break;
          case '.xml':
            res.inner.headers.set('Content-Type', 'text/xml; charset=utf-8');
            break;
          case '.json':
            res.inner.headers.set('Content-Type', 'text/json; charset=utf-8');
            break;
        }
        res.inner.write(content);
      } else {
        res.inner.statusCode = 404;
      }
    }
  };
}

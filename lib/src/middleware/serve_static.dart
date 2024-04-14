import 'dart:async';
import 'dart:io';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';

import '../http/http.dart';

/// 静态服务中间件
serveStatic(String path) {
  var baseUri = Directory.current.uri.resolve(path);
  var baseDir = Directory.fromUri(baseUri);
  return (Request req, Response res, Completer<String?> next) async {
    res as ResponseInternal;
    if (req.method == HttpMethod.httpGet) {
      var uri = baseDir.uri.resolve(req.uri.path.substring(1));
      var file = File.fromUri(uri);
      if (await file.exists()) {
        var fileName = basename(file.path);
        var mimeType = mime(fileName);
        mimeType = mimeType ?? 'application/octet-stream';
        var content = await file.readAsString();
        res.inner.headers.set('Content-Type', mimeType);
        res.inner.write(content);
      } else {
        res.inner.statusCode = 404;
      }
    }
  };
}

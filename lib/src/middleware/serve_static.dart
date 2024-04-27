import 'dart:async';
import 'dart:io';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';

import '../http/http.dart';

/// 静态服务中间件,[path]根路径,访问时,url不需要加上该path
serveStatic(String path) {
  var baseUri = Directory.current.uri.resolve(path);
  var baseDir = Directory.fromUri(baseUri);
  return (Request req, Response res, Completer<String?> next) async {
    res as ResponseInternal;
    if (req.method == HttpMethod.httpGet) {
      var uri = baseDir.uri.resolve(req.uri.path.substring(1));
      var file = File.fromUri(uri);
      if (await file.exists()) {
        await _getFile(req, res, file);
      } else {
        res.inner.statusCode = 404;
      }
    }
    next.complete();
  };
}

Future<void> _getFile(Request req, Response res, File file) async {
  res as ResponseInternal;
  var fileName = basename(file.path);
  var extensionName = extension(file.path);
  var mimeType = mime(fileName);
  mimeType = mimeType ?? 'application/octet-stream';
  var contentType = ContentType.parse(mimeType);
  dynamic content;
  if (extensionName == '.pck' ||
      extensionName == '.dll' ||
      extensionName == '.wasm' ||
      contentType.primaryType == 'image' ||
      contentType.primaryType == 'audio' ||
      contentType.primaryType == 'video' ||
      mimeType == 'application/octet-stream') {
    content = await file.openRead().pipe(res.inner);
  } else {
    content = await file.readAsString();
  }
  res.headers.set('Content-Type', mimeType);
  res.statusCode = 200;
  res.send(content);
}

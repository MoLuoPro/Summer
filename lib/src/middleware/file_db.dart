import 'dart:async';
import 'dart:io';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';

import '../http/http.dart';

/// 静态服务中间件
fileDB(String path) {
  // var baseUri = Directory.current.uri.resolve(path);
  // var baseDir = Directory.fromUri(baseUri);
  var baseDir = Directory.current;
  return (Request req, Response res, Completer<String?>? next) async {
    res as ResponseInternal;
    if (req.method == HttpMethod.httpGet) {
      var uri = baseDir.uri.resolve(path + req.uri.path);
      var file = File.fromUri(uri);
      var dir = Directory.fromUri(uri);
      if (await file.exists()) {
        await _getFile(req, res, file);
      } else if (await dir.exists()) {
        await _getDirectory(req, res, dir, baseDir);
      } else {
        res.inner.statusCode = 404;
      }
    }
  };
}

Future<void> _getDirectory(
    Request req, Response res, Directory directory, Directory baseDir) async {
  if (await directory.exists()) {
    var entrys = await directory.list().toList();
    var html = '<html><body><ul>';
    for (var entry in entrys) {
      var name = basename(entry.path);
      var path = '';
      path = relative(entry.path, from: baseDir.path).replaceAll('\\', '/');
      html += '<li><a href="${req.requestedUri.origin}/$path">$name</li>';
    }
    html += '</ul></body></html>';
    res.headers.contentType = ContentType.html;
    res.statusCode = 200;
    res.send(html);
  } else {
    throw Exception('Directory dose not exists.');
  }
}

Future<void> _getFile(Request req, Response res, File file) async {
  if (await file.exists()) {
    var fileName = basename(file.path);
    var mimeType = mime(fileName);
    mimeType = mimeType ?? 'application/octet-stream';
    res.statusCode = 200;
    res.headers.set('Content-Disposition', 'attachment; filename="$fileName"');
    res.headers.set('Content-Type', mimeType);
    res.sendAll(await file.readAsBytes());
  } else {
    throw Exception('File dose not exists.');
  }
}

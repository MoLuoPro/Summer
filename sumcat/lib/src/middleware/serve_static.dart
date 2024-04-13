import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sumcat/src/http/http.dart';

///静态服务中间件
serveStatic(String path) {
  var baseUri = Directory.current.uri.resolve(path);
  var baseDir = Directory.fromUri(baseUri);
  return (Request req, Response res, Completer<String?> next) async {
    res as ResponseInternal;
    if (req.method == HttpMethod.httpGet) {
      var uri = baseDir.uri.resolve(req.uri.path.substring(1));
      var file = File.fromUri(uri);
      if (await file.exists()) {
        var fileType = extension(file.path);
        var content = await file.readAsString();
        late String contentType;
        switch (fileType) {
          case '.html':
            contentType = 'text/html; charset=utf-8';
            break;
          case '.js':
            contentType = 'text/javascript; charset=utf-8';
            break;
          case '.css':
            contentType = 'text/css; charset=utf-8';
            break;
          case '.xml':
            contentType = 'text/xml; charset=utf-8';
            break;
          case '.json':
            contentType = 'text/json; charset=utf-8';
            break;
          case '.mp4':
            contentType = 'video/mp4';
            break;
          case '.webm':
            contentType = 'video/webm';
            break;
          case '.ogg':
            contentType = 'video/ogg';
            break;
          case '.jpeg':
            contentType = 'image/jpeg';
            break;
          case '.png':
            contentType = 'image/png';
            break;
          case '.gif':
            contentType = 'image/gif';
            break;
          case '.svg':
            contentType = 'image/svg+xml';
            break;
          case '.ttf':
            contentType = 'font/ttf';
            break;
          case '.otf':
            contentType = 'font/otf';
            break;
          case '.woff':
            contentType = 'font/woff';
            break;
          case '.woff2':
            contentType = 'font/woff2';
            break;
          case '.pdf':
            contentType = 'application/pdf';
            break;
          default:
            throw Exception('Content-Type none exists');
        }
        res.inner.headers.set('Content-Type', contentType);
        res.inner.write(content);
      } else {
        res.inner.statusCode = 404;
      }
    }
  };
}

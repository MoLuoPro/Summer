import 'dart:async';
import 'dart:io';

import 'package:sumcat/sumcat.dart';

void main() {
  var app = createApp();
  app.ws('/talk', [
    (Request req, WebSocket ws, Completer<String?> next) {
      ws.listen((event) {
        print(event);
      });
    }
  ]);
  app.listen(httpPort: 4000);
}

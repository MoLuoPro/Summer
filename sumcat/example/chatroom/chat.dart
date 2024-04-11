import 'dart:io';

import 'package:sumcat/sumcat.dart';

Router chat = _init();

Router _init() {
  chat = Router();
  Set<WebSocket> sockets = {};
  chat.ws('/chat', [
    (req, ws) {
      sockets.add(ws);
      ws.listen((event) {
        for (var socket in sockets) {
          socket.add(event);
        }
      });
    }
  ]);
  return chat;
}

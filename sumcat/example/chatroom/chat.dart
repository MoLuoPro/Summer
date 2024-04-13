import 'dart:io';

import 'package:sumcat/sumcat.dart';

WebSocketRouter chat = _init();

WebSocketRouter _init() {
  chat = webSocketRouter();
  Set<WebSocket> sockets = {};
  chat.ws('/chat', [
    (req, ws, next) {
      sockets.add(ws);
      ws.listen((event) {
        for (var socket in sockets) {
          print(event);
          socket.add(event);
        }
      });
      next.complete();
    }
  ]);
  return chat;
}

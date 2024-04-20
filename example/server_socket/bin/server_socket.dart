import 'dart:io';

import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.tcp((socket, next) {
    socket.listen((event) {
      print(event);
    });
  });
  app.udp((socket, next) {
    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        var data = socket.receive();
        if (data != null) {
          print(data.data);
        }
      }
    });
  });
  app.listen(tcpPort: 4000, udpPort: 5000);
}

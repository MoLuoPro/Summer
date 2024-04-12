import 'dart:convert';
import 'dart:io';

import 'package:sumcat/sumcat.dart';

void main() {
  var app = createApplication();
  app.tcp([
    (client, next) async {
      client.listen((event) {
        print(event);
      });
    }
  ]);
  app.udp([
    (client, next) async {
      client.listen((event) {
        if (event == RawSocketEvent.read) {
          var datagram = client.receive();
          if (datagram != null) {
            var message = utf8.decode(datagram.data);
            print(message);
            if (message == 'quit') {
              client.close();
            }
          }
        }
      });
    }
  ]);
  app.listen(tcpPort: 4000, udpPort: 4100);
}

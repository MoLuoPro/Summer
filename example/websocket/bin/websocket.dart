import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.ws('webSocket', [
    (req, ws, next) {
      ws.listen((event) {
        print(event);
      });
    }
  ]);
  app.listen(httpPort: 4000);
}

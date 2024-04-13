import 'package:sumcat/sumcat.dart';

void main() {
  var app = createApp();
  app.ws('/talk', [
    (req, ws, next) {
      ws.listen((event) {
        print(event);
      });
    }
  ]);
  app.listen(httpPort: 4000);
}

import 'package:sumcat/sumcat.dart';

void main() {
  var app = createApplication();
  app.ws('/talk', [
    (req, ws) {
      ws.listen((event) {
        print(event);
      });
    }
  ]);
  app.listen(4000);
}

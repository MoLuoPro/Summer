import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.get('/test', [
    (Request req, Response res) {
      return 'test finished';
    }
  ]);
  app.listen(httpPort: 4000);
}

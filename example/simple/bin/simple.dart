import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();

  app.get('/test', [
    (req, res, next) {
      next.complete();
    },
    (req, res, next) {
      return 'test finished';
    }
  ]);
  app.listen(httpPort: 4000);
}

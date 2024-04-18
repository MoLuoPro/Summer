import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();

  app.get('/test', [
    (req, res, next) {
      next.complete();
    },
    (req, res, next) {
      return [5, 6, 87, 1, 324, 561, 354, 651, 65];
    }
  ]);
  app.listen(httpPort: 4000);
}

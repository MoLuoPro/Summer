import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  var router = httpRouter();
  router.get('/test', [
    (req, res, next) {
      return 'test';
    }
  ]);
  app.useHttpRouter(path: '/index', router: router);
  app.listen(httpPort: 4000);
}

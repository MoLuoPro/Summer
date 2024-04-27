import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.use(fns: [
    (req, res, next) {
      res.headers.set('Cross-Origin-Embedder-Policy', 'require-corp');
      res.headers.set('Cross-Origin-Opener-Policy', 'same-origin');
      next.complete();
    },
    serveStatic('public')
  ]);
  app.listen(httpPort: 4000);
}

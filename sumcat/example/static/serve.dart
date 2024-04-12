import 'package:sumcat/sumcat.dart';

void main() {
  var app = createApplication();
  app.use(fns: [serveStatic('html')]);
  app.listen(httpPort: 4000);
}

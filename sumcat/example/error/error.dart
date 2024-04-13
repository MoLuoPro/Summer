import 'package:sumcat/sumcat.dart';

void main() {
  var app = createApp();
  app.get('/index', [
    (req, res, next) {
      throw Error();
    },
    (err, req, res, next) {
      print(err);
    }
  ]);
  app.listen(httpPort: 4000);
}

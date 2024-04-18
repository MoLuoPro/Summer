import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.get('/test', [
    (req, res, next) async {
      print(await req.body);
    }
  ]);
  app.listen(httpPort: 4000);
}

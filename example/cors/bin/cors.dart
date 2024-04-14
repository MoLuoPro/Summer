import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  var corsOptions = {'origin': 'http://localhost:4200'};
  app.use(path: '*', fns: [cors(corsOptions)]);
  app.get('/test', [
    (req, res) {
      print('test');
    }
  ]);
  app.listen(httpPort: 4000);
}

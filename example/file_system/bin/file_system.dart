import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.use(fns: [fileDB('files')]);
  app.listen(httpPort: 4000);
}

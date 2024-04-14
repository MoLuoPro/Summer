import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.get('/download', [
    (Request req, Response res) async {
      await res.download('files/file.txt');
    }
  ]);
  app.listen(httpPort: 4000);
}

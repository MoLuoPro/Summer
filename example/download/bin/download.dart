import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.get('/download', [
    (req, res, next) async {
      await res.downloadFile('files/file.txt');
    }
  ]);
  app.listen(httpPort: 4000);
}

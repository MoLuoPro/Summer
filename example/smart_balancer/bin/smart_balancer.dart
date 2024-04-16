import 'package:summer/summer.dart';

void main(List<String> arguments) async {
  var app = createApp();
  var balancer = await smartBalancer();
  print(balancer is HttpHandler);
  print(balancer is HttpErrorSimpleHandler);
  // app.use(fns: [balancer]);
  // app.get('/test', [
  //   (Request req, Response res) {
  //     print('finished');
  //   }
  // ]);
  // app.listen(httpPort: 4000);
}

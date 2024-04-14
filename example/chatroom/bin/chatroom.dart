import 'package:summer/summer.dart';

import './chat.dart';
import './login.dart';

late Application app;

void main() {

  var port = 4000;
  app = createApp();
  
  app
    ..useWebSocketRouter(router: chat)
    ..useHttpRouter(router: login);

  print("Server is running on port $port...");
  app.listen(httpPort: port);
}

import 'package:sumcat/sumcat.dart';

import './chat.dart';
import './login.dart';

late Application app;

void main() {
  app = createApp();
  app
    ..useWebSocketRouter(router: chat)
    ..useHttpRouter(router: login);
  app.listen(httpPort: 4000);
}

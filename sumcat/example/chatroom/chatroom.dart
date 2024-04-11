import 'package:sumcat/sumcat.dart';

import './chat.dart';
import './login.dart';

late Application app;

void main() {
  app = createApplication();
  app
    ..useRouter(router: chat)
    ..useRouter(router: login);
  app.listen(4000);
}

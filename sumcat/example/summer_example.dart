import 'dart:async';

import 'package:sumcat/sumcat.dart';

void main() {
  var app = createApp();
  var router = httpRouter();
  //请求
  router.get("/user/:id", [
    (Request req, Response res, Completer<String?> next) async {
      await Future.delayed(Duration(seconds: 1));
      res.ok("test1 completed");
      next.complete();
    },
    (Request req, Response res, Completer<String?> next) {
      res.ok("id is ${req.params['id']}");
      next.complete();
    }
  ]);
  //中间件
  router.use(path: '/user', fns: [
    (Request req, Response res, Completer<String?> next) {
      print('use');
      next.complete();
    }
  ]);
  //参数前置处理器
  router.param('id', (Request req, Response res, Completer<String?> next,
      String value, String name) {
    print(req.params);
    req.params.update('id', (val) => '${int.parse(value) + 10}');
    next.complete();
  });
  //路由器
  app.useHttpRouter(path: '/dart', router: router);
  app.listen(httpPort: 4000);
}

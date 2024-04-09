import 'dart:async';
import 'dart:ffi';
import 'package:sumcat/sumcat.dart';

void main() {
  var app = createApplication();
  var router = Router();
  //请求
  router.get("/user/:id", [
    (HttpRequestWrapper req, HttpResponseWrapper res, Completer<String?> next) {
      res.inner.writeln("test1 completed");
      next.complete();
    },
    (HttpRequestWrapper req, HttpResponseWrapper res, Completer<String?> next) {
      res.inner.writeln("id is ${req.params['id']}");
      next.complete();
    }
  ]);
  //中间件
  router.use(path: '/user', fns: [
    (req, res, next) {
      print('use');
      next.complete();
    }
  ]);
  //参数前置处理器
  router.param('id', (req, res, next, value, name) {
    print('$name: $value');
    print(req.params);
    req.params.update('id', (value) => int.parse(value) + 10);
    next.complete();
  });
  //路由器
  app.useRouter(path: '/dart', router: router);
  app.listen(4000);
}

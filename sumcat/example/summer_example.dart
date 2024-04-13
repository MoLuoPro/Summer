import 'package:sumcat/sumcat.dart';

void main() {
  var app = createApp();
  var router = HttpRouter();
  //请求
  router.get("/user/:id", [
    (req, res, next) async {
      await Future.delayed(Duration(seconds: 1));
      res.inner.writeln("test1 completed");
      next.complete();
    },
    (req, res, next) {
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
    print(req.params);
    req.params.update('id', (value) => int.parse(value) + 10);
    next.complete();
  });
  //路由器
  app.useHttpRouter(path: '/dart', router: router);
  app.listen(httpPort: 4000);
}

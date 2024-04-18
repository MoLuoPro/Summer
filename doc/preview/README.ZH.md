## Summer
Powerful Server Framework behind Spring  

## 例子
#### 简单的例子
``` dart
import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.get('/test', [
    (Request req, Response res) {
      return 'test finished';
    }
  ]);
  app.listen(httpPort: 4000);
}
```
createApp()创建应用实例</br>
app.get定义一个get请求,'/test'为路径,后面的回调函数负责执行业务逻辑.</br>
app.listen(httpPort: 4000);启动服务器并监听4000端口.

#### 中间件
```dart
import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  var corsOptions = {'origin': 'http://localhost:4200'};
  app.use(fns: [cors(corsOptions)]);
  app.get('/test', [
    (Request req, Response res) {
      print('test');
    }
  ]);
  app.listen(httpPort: 4000);
}
```
以cors中间件为例,cors()会返回函数,使用app.use(fns: [cors(corsOptions)])就可将中间件注册.

#### 路由管理器
```dart
import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  var router = httpRouter();
  router.get('/test', [
    (Request req, Response res) {
      return 'test';
    }
  ]);
  app.useHttpRouter(path: '/index', router: router);
  app.listen(httpPort: 4000);
}
```
创建路由管理器,并使用app.useHttpRouter将路由管理器注册进应用,访问接口的路径为/index/test

#### 文件系统
``` dart
import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.use(fns: [fileDB('files')]);
  app.listen(httpPort: 4000);
}
```
引入fileDB中间件,输入"http://localhost:4000"即可访问files文件夹.

#### 静态资源服务
``` dart
import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.use(fns: [serveStatic('htmls')]);
  app.listen(httpPort: 4000);
}
```
引入serveStatic中间件,输入"http://localhost:4000"即可访问htmls文件夹下的静态资源.

#### 下载
``` dart
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
```
调用res.downloadFile('files/file.txt');前端会下载该文件.
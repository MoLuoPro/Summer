## Summer
优雅而强大的Dart Web框架。借鉴了Express.js等开源库，使用Dart语言编写，支持路由管理，中间件，静态文件托管，以及各种常用的功能。  

### 简单的例子
``` dart
import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.get('/test', [
    (req, res, next) {
      return 'test finished';
    }
  ]);
  app.listen(httpPort: 4000);
}
```
createApp()创建应用实例</br>
app.get定义一个get请求,'/test'为路径,后面的回调函数负责执行业务逻辑.</br>
app.listen(httpPort: 4000);启动服务器并监听4000端口.

### 中间件
```dart
import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  var corsOptions = {'origin': 'http://localhost:4200'};
  app.use(fns: [cors(corsOptions)]);
  app.get('/test', [
    (req, res, next) {
      print('test');
    }
  ]);
  app.listen(httpPort: 4000);
}
```
以cors中间件为例,cors()会返回函数,使用app.use(fns: [cors(corsOptions)])就可将中间件注册.

### 路由管理器
```dart
import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  var router = httpRouter();
  router.get('/test', [
    (req, res, next) {
      return 'test';
    }
  ]);
  app.useHttpRouter(path: '/index', router: router);
  app.listen(httpPort: 4000);
}
```
创建路由管理器,并使用app.useHttpRouter将路由管理器注册进应用,访问接口的路径为/index/test

### 文件系统
``` dart
import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.use(fns: [fileDB('files')]);
  app.listen(httpPort: 4000);
}
```
引入fileDB中间件,输入"http://localhost:4000"即可访问files文件夹.

### 静态资源服务
``` dart
import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.use(fns: [serveStatic('htmls')]);
  app.listen(httpPort: 4000);
}
```
引入serveStatic中间件,输入"http://localhost:4000"即可访问htmls文件夹下的静态资源.

### 下载
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

API:
http请求
``` dart
import 'package:summer/summer.dart';

var app = createApp();
app.get('/path', [(req, res, next) => next.complete(), (req, res, next) => 'test']);
app.listen(httpPort: 4000);
```
引入summer包后,需要调用createApp创建应用,然后可以调用app.get(http方法),输入路径以及回调函数.
回调函数中的next类似于express的next,只不过summer是调用next.complete()来继续执行函数的.
最后调用app.listen开启服务器.

### 支持websocket
``` dart
import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.ws('webSocket', [
    (req, ws, next) {
      ws.listen((event) {
        print(event);
      });
    }
  ]);
  app.listen(httpPort: 4000);
}
``` 

### tcp,udp
``` dart
import 'dart:io';

import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.tcp((socket, next) {
    socket.listen((event) {
      print(event);
    });
  });
  app.udp((socket, next) {
    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        var data = socket.receive();
        if (data != null) {
          print(data.data);
        }
      }
    });
  });
  app.listen(tcpPort: 4000, udpPort: 5000);
}
```

``` dart
app.use(path: '/', fns:[...]);
```
app.use用来注册中间件,传递一个Handler函数数组,目前仅支持HttpHandler.path为可选值,符合该路径才调用.

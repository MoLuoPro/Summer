## Summer
优雅而强大的Dart Web框架。借鉴了Express.js等开源库，支持路由管理，中间件，静态文件托管，以及各种常用的功能  

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

`app.get`定义一个get请求，`/test`为路径，后面的回调函数负责执行业务逻辑  
`app.listen(httpPort: 4000)`，启动HTTP服务，并监听4000端口  



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

以`cors`中间件为例，`cors()`会返回函数  
使用`app.use(fns: [cors(corsOptions)])`就可将中间件注册  



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

创建路由管理器，并使用`app.useHttpRouter`将路由管理器注册进应用，访问接口的路径为`/index/test`  



### 文件系统

``` dart
import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.use(fns: [fileDB('files')]);
  app.listen(httpPort: 4000);
}
```  

引入fileDB中间件，输入`http://localhost:4000`，即可访问`files`文件夹  



### 静态网站  

``` dart
import 'package:summer/summer.dart';

void main(List<String> arguments) {
  var app = createApp();
  app.use(fns: [serveStatic('htmls')]);
  app.listen(httpPort: 4000);
}
```  

引入`serveStatic`中间件，输入`http://localhost:4000`即可访问htmls文件夹下的静态网站  



### 文件下载

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

调用`res.downloadFile('files/file.txt')`  




## API请求

### HTTP  

``` dart
import 'package:summer/summer.dart';

var app = createApp();
app.get('/path', [(req, res, next) => next.complete(), (req, res, next) => 'test']);
app.listen(httpPort: 4000);
```  

引入`summer`包后，需要调用`createApp`创建应用，然后可以调用`app.get(http方法)`，输入路径以及回调函数  

回调函数中的`next`类似于`express`的`next`，只不过`summer`是调用`next.complete()`来继续执行函数的  



### WebSocket

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



### TCP/UDP

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

`app.use`用来注册中间件，传递一个`Handler`函数数组，目前仅支持`HttpHandler.path`为可选值，符合该路径才调用  

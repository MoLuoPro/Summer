import 'dart:async';
import 'dart:isolate';

import 'package:summer/src/http/http.dart';

Future<HttpHandler> smartBalancer([Map<String, dynamic>? options]) async {
  options ??= {};
  var poolSize = options['poolSize'] ?? 4;
  var method = options['balanceMethod'] ?? BalanceMethods.ROUND_ROBIN;

  var pool = await createPool(poolSize);
  var methodFactory = MethodFactory(pool);
  var balancer = methodFactory.methodFactory(method);
  return (req, res, next) async {
    balancer.balance(req, res, next);
  };
}

Future<ThreadPool> createPool(int poolSize) async {
  List<Isolate> pool = [];
  List<SendPort> sendPorts = [];
  ReceivePort receivePort = ReceivePort();
  StreamController streamController = StreamController.broadcast();
  for (int i = 0; i < poolSize; i++) {
    pool.add(await Isolate.spawn((SendPort sendPort) {
      final port = ReceivePort();
      sendPorts.add(port.sendPort);
      sendPort.send(port.sendPort);
      port.listen((task) async {
        task as Task;
        var result = await task._fn.call();
        task.completer?.complete();
        sendPort.send(result);
        streamController.add(Result(task.threadId, result));
        // receivePort.sendPort.send(Result(task.threadId, result));
      });
    }, receivePort.sendPort, debugName: i.toString()));
  }
  return ThreadPool(pool, receivePort, sendPorts, streamController);
}

class ThreadPool {
  late final ReceivePort _receivePort;
  late final List<Isolate> _threads;
  late final List<SendPort> _sendPorts;
  late final StreamController _streamController;

  ThreadPool(this._threads, this._receivePort, this._sendPorts,
      this._streamController);

  List<SendPort> get sendPorts => _sendPorts;
  ReceivePort get receivePort => _receivePort;
  List<Isolate> get threads => _threads;
  int get poolSize => _threads.length;
  StreamController get streamController => _streamController;
}

class Task {
  final Function _fn;
  final Completer<String?>? _completer;
  final SendPort _sendPort;
  final int threadId;

  Task(this._fn, this._completer, this._sendPort, this.threadId);

  Function get fn => _fn;
  Completer<String?>? get completer => _completer;
  SendPort get sendPort => _sendPort;
}

class Result {
  int threadId;
  dynamic data;
  Result(this.threadId, this.data);
}

abstract class BalanceMethod {
  FutureOr<void> balance(Request req, Response res, Comparable<String?> next);
}

class RoundRobin extends BalanceMethod {
  final ThreadPool _threadPool;
  int _cur = 0;

  RoundRobin(this._threadPool);

  ThreadPool get threadPool => _threadPool;

  @override
  FutureOr<void> balance(Request req, Response res, Comparable<String?> next) {
    req as RequestInternal;
    req.threadId = _cur % _threadPool.poolSize == 0 ? _cur = 0 : _cur++;
    req.threadPool = _threadPool;
  }
}

class MethodFactory {
  final ThreadPool _threadPool;
  MethodFactory(this._threadPool);

  BalanceMethod methodFactory(BalanceMethods method) {
    switch (method) {
      case BalanceMethods.ROUND_ROBIN:
        return RoundRobin(_threadPool);
      default:
        throw Exception('Non-existent method');
    }
  }
}

enum BalanceMethods {
  ROUND_ROBIN,
  WEIGHT_ROUND_ROBIN,
  LEAST_CONNECTIONS,
  WEIGHT_LEAST_CONNECTIONS,
  IP_HASH,
  LEAST_RESPONSE_TIME
}

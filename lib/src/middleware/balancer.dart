import 'dart:isolate';
import 'dart:math';
import 'dart:mirrors';

import 'package:summer/summer.dart';

HttpHandler balancer(Map<String, dynamic>? options) {
  options ??= {};
  var poolSize = options['poolSize'] ?? 4;
  return (req, res, next) {};
}

// List<Isolate> _createPool(int poolSize) {
//   List<Isolate> pool = [];
//   for (int i = 0; i < poolSize; i++) {
//     ReceivePort().sendPort;
//     pool.add(Isolate());
//   }
// }

import 'dart:io';

import '../router/router.dart';

abstract class Request implements HttpRequest {
  late HttpRequest _request;
  late Route route;

  Request(HttpRequest request) {
    _request = request;
  }
}

abstract class Response implements HttpResponse {
  late HttpResponse _response;

  Response(HttpResponse response) {
    _response = response;
  }
}

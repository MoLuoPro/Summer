import 'dart:async';

import '../http/http.dart';

HttpHandler cors([Map<String, dynamic>? options]) {
  dynamic origin = '*';
  List<String> methods = ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE'];
  List<String> allowedHeaders = [
    'Content-Type',
    'Authorization',
    'Content-Length',
    'X-Requested-With'
  ];
  bool credentials = false;
  int maxAge = 86400;
  List<String> exposedHeaders = [];
  Map<String, dynamic> headers = {};
  bool preflightContinue = false;
  int optionsSuccessStatus = 204;
  if (options != null) {
    origin = options['origin'] ?? origin;
    methods = options['methods'] ?? methods;
    allowedHeaders = options['allowedHeaders'] ?? allowedHeaders;
    credentials = options['credentials'] ?? credentials;
    exposedHeaders = options['exposedHeaders'] ?? exposedHeaders;
    preflightContinue = options['preflightContinue'] ?? preflightContinue;
    optionsSuccessStatus =
        options['optionsSuccessStatus'] ?? optionsSuccessStatus;
  }

  return (Request req, Response res, Completer<String?> next) async {
    configureOrigin() {
      var requestOrigin = req.headers.value('Access-Control-Allow-Origin');
      bool isAllowed = false;
      if (origin == '*') {
        res.headers.set('Access-Control-Allow-Origin', '*');
      } else if (origin is String) {
        res.headers.set('Access-Control-Allow-Origin', origin);
        res.headers.set('Vary', 'Origin');
      } else {
        isAllowed = _isOriginAllowed(requestOrigin, origin);
        res.headers.set('Vary', 'Origin');
        res.headers.set('Access-Control-Allow-Origin',
            isAllowed ? requestOrigin ?? '' : false);
        res.headers.set('Vary', 'Origin');
      }
    }

    configureCredentials() {
      if (credentials == true) {
        res.headers.set('Access-Control-Allow-Credentials', true);
      }
    }

    configureMethods() {
      res.headers.set('Access-Control-Allow-Methods', methods.join(','));
    }

    configureAllowedHeaders() {
      res.headers.set('Access-Control-Allow-Headers', allowedHeaders.join(','));
    }

    configureMaxAge() {
      res.headers.set('Access-Control-Max-Age', maxAge.toString());
    }

    configureExposedHeaders() {
      res.headers
          .set('Access-Control-Expose-Headers', exposedHeaders.join(','));
    }

    applyHeaders() {
      applyHeaders(headers) {
        for (var key in headers.keys) {
          if (headers[key] is List) {
            applyHeaders(headers[key]);
          } else {
            res.headers.set(key, headers[key]);
          }
        }
      }

      applyHeaders(headers);
    }

    if (options == null) {
      next.complete();
    } else {
      if (req.method == HttpMethod.httpOptions) {
        configureOrigin();
        configureCredentials();
        configureMethods();
        configureAllowedHeaders();
        configureMaxAge();
        configureExposedHeaders();
        applyHeaders();

        if (preflightContinue) {
          next.complete();
        } else {
          res.sendStatus(optionsSuccessStatus);
          res.headers.set('Content-Length', '0');
          await res.close();
        }
      } else {
        configureOrigin();
        configureCredentials();
        configureExposedHeaders();
        applyHeaders();
        next.complete();
      }
    }
  };
}

bool _isOriginAllowed(origin, allowedOrigin) {
  if (allowedOrigin is List) {
    for (var i = 0; i < allowedOrigin.length; ++i) {
      if (_isOriginAllowed(origin, allowedOrigin[i])) {
        return true;
      }
    }
    return false;
  } else if (allowedOrigin is String) {
    return origin == allowedOrigin;
  } else if (allowedOrigin is RegExp) {
    return allowedOrigin.hasMatch(origin);
  } else {
    return allowedOrigin != null;
  }
}
